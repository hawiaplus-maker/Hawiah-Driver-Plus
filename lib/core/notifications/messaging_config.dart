import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';

@pragma('vm:entry-point')
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

late final GlobalKey<NavigatorState> navigatorKey;

/// ================= BACKGROUND HANDLERS =================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showLocalNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (response.payload == null) return;
  final data = jsonDecode(response.payload!);
  handleNotificationTap(data);
}

/// ================= NOTIFICATION DATA =================

enum NotificationType { trackOrder }

class NotificationData {
  final NotificationType type;
  final int? orderId;

  NotificationData._({
    required this.type,
    this.orderId,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    switch (map['notification_type']?.toString()) {
      case '1':
        return NotificationData._(
          type: NotificationType.trackOrder,
          orderId: int.tryParse(map['order_id']?.toString() ?? ''),
        );
      default:
        throw ArgumentError(
          'Unsupported notification type: ${map['notification_type']}',
        );
    }
  }
}

/// ================= LOCAL NOTIFICATION =================

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;

  // في iOS أحيانًا notification = null (data-only)
  if (notification == null && message.data.isEmpty) return;

  final payload = jsonEncode(message.data);

  await _localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    notification?.title ?? message.data['title'],
    notification?.body ?? message.data['body'],
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance',
        'High Importance Notifications',
        channelDescription: 'Important notifications',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('custom_sound'),
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'custom_sound.caf',
      ),
    ),
    payload: payload,
  );
}

/// ================= TAP HANDLING =================

void handleNotificationTap(Map<String, dynamic> data) {
  log('Notification tapped with data: $data');

  try {
    final notificationData = NotificationData.fromMap(data);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;

      if (ctx == null || !ctx.mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (navigatorKey.currentContext?.mounted ?? false) {
            _performNavigation(notificationData);
          }
        });
        return;
      }

      _performNavigation(notificationData);
    });
  } catch (e) {
    log('Notification tap error: $e');
  }
}

void _performNavigation(NotificationData data) {
  final ctx = navigatorKey.currentContext!;
  switch (data.type) {
    case NotificationType.trackOrder:
      NavigatorMethods.pushNamed(ctx, LayoutScreen.routeName);
      break;
  }
}

/// ================= MESSAGING SERVICE =================

class MessagingService {
  MessagingService._();

  static Future<RemoteMessage?> init({
    required GlobalKey<NavigatorState> navKey,
  }) async {
    navigatorKey = navKey;

    /// Firebase init
    await Firebase.initializeApp();

    /// Android channel
    await _createAndroidChannel();

    /// Local notifications init
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          handleNotificationTap(jsonDecode(response.payload!));
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    /// Request permission (iOS APNs)
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      provisional: false,
    );

    log('Notification permission: ${settings.authorizationStatus}');

    /// 🔑 IMPORTANT: wait for APNs token
    final apnsToken = await _firebaseMessaging.getAPNSToken();
    log('APNs Token: $apnsToken');

    /// Foreground
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    /// Background → App opened
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => handleNotificationTap(msg.data),
    );

    /// Terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage.data);
    }

    /// Background handler
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    return initialMessage;
  }

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance',
      'High Importance Notifications',
      description: 'Important notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
