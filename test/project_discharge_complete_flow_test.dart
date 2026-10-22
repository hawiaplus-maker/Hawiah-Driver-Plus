import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:hawiah_driver/features/order/presentation/widget/discharge_action_widget.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:hawiah_driver/main.dart' show genContext;
import 'package:hive/hive.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:location/location.dart';

/// Serves the few translations the action needs, so the test doesn't depend
/// on the asset bundle.
class _TestAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'driverNotes': 'Driver notes',
      'driverNotesHint': 'Add notes (optional)',
      'captureAndComplete': 'Capture photo & finish',
      'cancel': 'Cancel',
      'completeDischarging': 'Complete Discharging',
      'handlePickup': 'Handle pickup',
      'completeDischargeSuccess': 'Discharge completed',
      'startTripSuccess': 'Trip started',
      'cameraNotAvailable': 'Camera not available',
      'pleaseEnableLocation': 'Please enable location',
      'anErrorOccurred': 'An error occurred',
    };
  }
}

/// Returns the prepared photo instead of opening the camera.
class _FakeImagePicker extends ImagePickerPlatform {
  _FakeImagePicker(this.file);

  final File file;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async =>
      XFile(file.path);

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async =>
      XFile(file.path);
}

/// A location service that always answers instantly.
class _FakeLocationService extends LocationService {
  @override
  Future<bool> checkAndRequestLocationService() async => true;

  @override
  Future<bool> checkAndRequestLocationPermission() async => true;

  @override
  Future<LocationData?> getLocationForAction({
    Duration timeout = const Duration(seconds: 12),
  }) async =>
      LocationData.fromMap({'latitude': 24.7136, 'longitude': 46.6753});
}

/// Records the upload instead of sending it to the API.
class _FakeOrderCubit extends OrderCubit {
  int? completedPickupId;
  File? uploadedImage;
  double? uploadedLatitude;
  double? uploadedLongitude;
  String? uploadedNotes;

  @override
  Future<void> completeProjectDischarge({
    required int pickupId,
    required File image,
    required double latitude,
    required double longitude,
    String? driverNotes,
  }) async {
    completedPickupId = pickupId;
    uploadedImage = image;
    uploadedLatitude = latitude;
    uploadedLongitude = longitude;
    uploadedNotes = driverNotes;

    emit(DischargeActionLoading(pickupId));
    emit(DischargeActionSuccess(pickupId, 'Discharge completed'));
  }
}

Future<File> _writeFakePhoto(Directory dir) async {
  final file = File('${dir.path}/photo.jpg');
  // A "photo" that is big enough to be worth compressing.
  await file.writeAsBytes(List<int>.filled(600 * 1024, 7));
  return file;
}

/// A location service whose GPS never finds a fix.
class _StuckLocationService extends LocationService {
  @override
  Future<bool> checkAndRequestLocationService() async => true;

  @override
  Future<bool> checkAndRequestLocationPermission() async => true;

  @override
  Future<LocationData> getLocation() => Completer<LocationData>().future;
}

void main() {
  late Directory tempDir;
  late File photo;
  late _FakeOrderCubit cubit;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hawiah_discharge_test');
    final hiveDir = await Directory.systemTemp.createTemp('hawiah_hive_test');
    Hive.init(hiveDir.path);
    await Hive.openBox('app');
    photo = await _writeFakePhoto(tempDir);
  });

  setUp(() async {
    cubit = _FakeOrderCubit();
    // The location service is resolved through the service locator.
    if (sl.isRegistered<LocationService>()) {
      await sl.unregister<LocationService>();
    }
    sl.registerSingleton<LocationService>(_FakeLocationService());
    ImagePickerPlatform.instance = _FakeImagePicker(photo);
  });

  tearDown(() async {
    ImagePickerPlatform.instance = _FakeImagePicker(photo);
  });

  Future<void> pumpAction(WidgetTester tester) async {
    // A phone sized viewport — the bottom sheet is designed for one.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(381, 828),
        builder: (context, child) {
          return EasyLocalization(
            supportedLocales: const [Locale('en'), Locale('ar')],
            path: 'assets/translations',
            startLocale: const Locale('en'),
            fallbackLocale: const Locale('en'),
            saveLocale: false,
            useOnlyLangCode: true,
            assetLoader: _TestAssetLoader(),
            child: BlocProvider<AppThemeCubit>(
              create: (_) => AppThemeCubit()..initial(),
              child: BlocProvider<OrderCubit>.value(
                value: cubit,
                child: Builder(
                  builder: (context) => MaterialApp(
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    navigatorObservers: [BotToastNavigatorObserver()],
                    builder: (context, child) {
                      genContext = context;
                      // The app shows its toasts through BotToast.
                      return BotToastInit()(context, child);
                    },
                    home: Scaffold(
                      body: DischargeActionWidget(
                        dischargeId: 42,
                        isVisible: true,
                        label: 'Complete Discharging',
                        isFullWidth: true,
                        onComplete: ({
                          required image,
                          required latitude,
                          required longitude,
                          required driverNotes,
                        }) =>
                            cubit.completeProjectDischarge(
                          pickupId: 42,
                          image: image,
                          latitude: latitude,
                          longitude: longitude,
                          driverNotes: driverNotes,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the discharge is sent to the API after the photo is taken',
      (tester) async {
    await pumpAction(tester);

    // 1. The driver taps "Complete Discharging".
    await tester.tap(find.text('Complete Discharging'));
    await tester.pumpAndSettle();

    // 2. The notes sheet opens and shows its title.
    expect(find.text('Driver notes'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'container is empty');
    await tester.pump();

    // 3. The driver confirms and the photo is taken.
    await tester.tap(find.text('Capture photo & finish'));
    await tester.pumpAndSettle();

    // 4. The request reached the cubit with the photo and the position.
    expect(cubit.completedPickupId, 42);
    expect(cubit.uploadedImage, isNotNull);
    expect(cubit.uploadedLatitude, 24.7136);
    expect(cubit.uploadedLongitude, 46.6753);
    expect(cubit.uploadedNotes, 'container is empty');
    expect(tester.takeException(), isNull);
  });

  testWidgets('nothing is sent when the driver cancels the camera',
      (tester) async {
    ImagePickerPlatform.instance = _CancellingImagePicker();

    await pumpAction(tester);

    await tester.tap(find.text('Complete Discharging'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capture photo & finish'));
    await tester.pumpAndSettle();

    expect(cubit.completedPickupId, isNull);
    expect(tester.takeException(), isNull);
  });

  test('a GPS without a fix does not block the action forever', () async {
    final service = _StuckLocationService();

    final stopwatch = Stopwatch()..start();
    final location = await service.getLocationForAction(
      timeout: const Duration(milliseconds: 200),
    );
    stopwatch.stop();

    // The wait is capped — the driver is not stuck on a spinning screen.
    expect(location, isNull);
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
  });
}

/// A picker the driver cancels.
class _CancellingImagePicker extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async =>
      null;

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async =>
      null;
}
