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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showLocalNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  if (details.payload != null) {
    final data = jsonDecode(details.payload!);
    handleNotificationTap(data);
  }
}

enum NotificationType { trackOrder }

class NotificationData {
  final NotificationType type;
  final int? orderId;
  NotificationData._({required this.type, this.orderId});
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    switch (map['notification_type'] as String?) {
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

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final payload = jsonEncode(message.data);
  await _localNotifications.show(
    notification.hashCode,
    notification?.title,
    notification?.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance',
        'High Importance',
        channelDescription: 'Important notifications',
        sound: RawResourceAndroidNotificationSound('custom_sound'),
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(sound: 'custom_sound.caf'),
    ),
    payload: payload,
  );
}

void handleNotificationTap(Map<String, dynamic> data) {
  log('Handling notification tap with data: $data');
  try {
    final notificationData = NotificationData.fromMap(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) {
        log('Context not available, retrying...');
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
    log('Error handling notification tap: $e');
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

class MessagingService {
  MessagingService._();

  static Future<RemoteMessage?> init({
    required GlobalKey<NavigatorState> navKey,
  }) async {
    navigatorKey = navKey;
    await Firebase.initializeApp();
    await _createAndroidChannel();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          handleNotificationTap(data);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('Permission status: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((msg) async {
      await _showLocalNotification(msg);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      handleNotificationTap(msg.data);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) handleNotificationTap(initialMessage.data);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return initialMessage;
  }

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance',
      'High Importance',
      description: 'Important notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}
