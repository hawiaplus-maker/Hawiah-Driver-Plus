import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:location/location.dart';

/// Location helper of the app.
///
/// Besides the plain "where am I" calls the service keeps a warm cache of the
/// last known position: the position is detected when the app opens and is
/// kept up to date by the location stream. An action that needs the driver
/// position (finishing a discharge for instance) then reuses that cached
/// position right away instead of waiting for a new GPS fix.
///
/// The service is registered as a lazy singleton — every screen has to share
/// the same cache.
class LocationService with WidgetsBindingObserver {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  bool _isListening = false;

  /// The last known position of the driver.
  LocationData? _cachedLocation;

  /// The moment the cached position was captured.
  DateTime? _cachedAt;

  /// How long a cached position stays usable (in seconds).
  static const int cacheValidityInSeconds = 60;

  /// The distance (in meters) the driver has to move to get a new position.
  static const double distanceFilterInMeters = 10;

  /// The interval (in milliseconds) between two position updates.
  static const int updateIntervalInMs = 5000;

  LocationService() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// The last known position — `null` when nothing was detected yet.
  LocationData? get cachedLocation => _cachedLocation;

  /// True when the cached position is recent enough to be used as is.
  bool get hasFreshLocation {
    final cachedAt = _cachedAt;
    if (_cachedLocation == null || cachedAt == null) return false;
    return DateTime.now().difference(cachedAt).inSeconds <=
        cacheValidityInSeconds;
  }

  /// Detects the position when the app opens and keeps it up to date.
  ///
  /// The permission is asked for right away — the discharge flow attaches the
  /// position of the driver, so it has to be granted before the driver starts
  /// working. The location settings are *not* forced: the app keeps working
  /// without a position, the driver is asked for it again when an action
  /// needs it.
  ///
  /// Returns true when the permission is granted and the tracking started,
  /// false when the driver refused it.
  Future<bool> initLocationTracking() async {
    final granted = await checkAndRequestLocationPermission();
    print("[LocationService] location permission granted: $granted");
    if (!granted) return false;

    // The stream has to run from the start: it pushes the last known position
    // right away and the fresh fixes after that, so the cache is never left
    // empty. Waiting for a `getLocation()` call here would block (a GPS
    // without a fix never answers on its own) and the discharge actions would
    // then have nothing to send.
    startWatching();

    await _lastKnownLocation();
    return true;
  }

  /// The current position of the driver.
  ///
  /// The cached position is returned right away when it is still fresh,
  /// otherwise the same capped resolution as [getLocationForAction] is used.
  Future<LocationData?> getCurrentLocation() async {
    if (hasFreshLocation) return _cachedLocation;
    try {
      if (await checkAndRequestLocationService() &&
          await checkAndRequestLocationPermission()) {
        return await getLocationForAction();
      }
      return _cachedLocation;
    } catch (e) {
      print("Error getting location: $e");
      return _cachedLocation;
    }
  }

  /// The position the operating system already knows.
  ///
  /// It answers immediately (it never waits for a GPS fix) and it is the best
  /// starting point when the app opens or when an action needs a position.
  Future<LocationData?> _lastKnownLocation() async {
    try {
      final data = await _location.getLastKnownLocation();
      if (data != null) _cache(data);
      return data;
    } catch (e) {
      print("Error reading the last known location: $e");
      return null;
    }
  }

  /// A brand new position — the GPS fix is awaited and cached.
  Future<LocationData> getLocation() async {
    final data = await _location.getLocation();
    _cache(data);
    return data;
  }

  /// The position to attach to an action (finishing a discharge...).
  ///
  /// The result is resolved as fast as possible:
  ///
  /// 1. the position cached by this service (the stream keeps it fresh),
  /// 2. the position cached by the operating system,
  /// 3. the first update of the location stream — capped by [timeout], because
  ///    the plugin never gives up on its own: a driver without a GPS fix would
  ///    wait forever and the action would look dead.
  ///
  /// A cached position is the fallback of last resort, so the action can
  /// always be completed.
  Future<LocationData?> getLocationForAction({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (hasFreshLocation) return _cachedLocation;

    final lastKnown = await _lastKnownLocation();
    if (lastKnown != null && _isRecent(lastKnown)) return lastKnown;

    final streamFix = await _firstStreamFix(timeout);
    if (streamFix != null) return streamFix;

    // Nothing arrived in time — the last known position is better than
    // blocking the discharge.
    return _cachedLocation ?? lastKnown;
  }

  /// True when [data] was captured recently enough to describe where the
  /// driver is right now.
  bool _isRecent(
    LocationData data, {
    Duration maxAge = const Duration(minutes: 10),
  }) {
    final time = data.time;
    if (time == null) return true;
    final capturedAt = DateTime.fromMillisecondsSinceEpoch(time.toInt());
    return DateTime.now().difference(capturedAt) <= maxAge;
  }

  /// The first position delivered by the stream, or null when nothing arrives
  /// within [timeout].
  Future<LocationData?> _firstStreamFix(Duration timeout) async {
    try {
      final data = await _location.onLocationChanged.first.timeout(timeout);
      _cache(data);
      return data;
    } catch (e) {
      print("Error waiting for a position: $e");
      return null;
    }
  }

  /// Refreshes the cached position in the background.
  ///
  /// Used when the app comes back to the foreground: the driver may have
  /// moved while the app was in the background.
  Future<LocationData?> refreshLocation() async {
    try {
      if (!_isGranted(await _location.hasPermission())) return _cachedLocation;
      return await _lastKnownLocation() ?? _cachedLocation;
    } catch (e) {
      print("Error refreshing the location: $e");
      return _cachedLocation;
    }
  }

  Future<bool> checkAndRequestLocationService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    return serviceEnabled;
  }

  Future<bool> checkAndRequestLocationPermission() async {
    try {
      PermissionStatus permission = await _location.hasPermission();

      // "Approximate" location (coarse on Android 12+, reduced accuracy on
      // iOS) is enough for the app — it only needs to know where the driver
      // is, not a centimetre-accurate fix.
      if (_isGranted(permission)) return true;
      if (permission == PermissionStatus.deniedForever) return false;

      permission = await _location.requestPermission();
      return _isGranted(permission);
    } catch (e) {
      print("Error checking the location permission: $e");
      return false;
    }
  }

  /// True when [status] allows the app to read the position, including the
  /// approximate ("coarse" / "reduced accuracy") grant.
  bool _isGranted(PermissionStatus status) =>
      status == PermissionStatus.granted ||
      status == PermissionStatus.grantedLimited;

  void getLocationData(void Function(LocationData)? onData) async {
    _location.onLocationChanged.listen(onData);
  }

  void pauseLocationStream() {
    _locationSubscription?.pause();
    _isListening = false;
  }

  void resumeLocationStream() {
    if (_locationSubscription != null && !_isListening) {
      _locationSubscription?.resume();
      _isListening = true;
    }
  }

  void listenToLocation(void Function(LocationData) onData) {
    _locationSubscription?.cancel();
    _isListening = true;
    _locationSubscription = _location.onLocationChanged.listen(onData);
  }

  /// Starts refreshing the cached position in the background.
  void startWatching() {
    if (_isListening) return;
    _isListening = true;
    _locationSubscription?.cancel();
    _locationSubscription = _location.onLocationChanged.listen(
      _cache,
      onError: (Object error) => print("Location stream error: $error"),
    );
    unawaited(_applyStreamSettings());
  }

  /// Stops refreshing the cached position.
  void stopWatching() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isListening = false;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
  }

  /// Keeps the last known position — it is the one the actions reuse.
  void _cache(LocationData data) {
    _cachedLocation = data;
    _cachedAt = DateTime.now();
  }

  Future<void> _applyStreamSettings() async {
    try {
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterInMeters,
        interval: updateIntervalInMs,
      );
    } catch (e) {
      print("Error changing the location settings: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshLocation());
    }
  }
}
