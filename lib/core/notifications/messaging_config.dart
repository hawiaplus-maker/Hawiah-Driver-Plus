import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui; // ضروري لمعرفة لغة الجهاز في الخلفية

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';

@pragma('vm:entry-point')
final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

late final GlobalKey<NavigatorState> navigatorKey;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // إذا كان الإشعار يحتوي على "notification"، فأندرويد يظهره تلقائياً في الخلفية.
  // لذا لا نستدعي _showLocalNotification هنا لتجنب التكرار (إلا إذا كان data-only).
  if (message.notification == null) {
    await _showLocalNotification(message);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  if (details.payload != null) {
    final data = jsonDecode(details.payload!);
    handleNotificationTap(data);
  }
}

enum NotificationType { trackOrder, unknown }

class NotificationData {
  final NotificationType type;
  final int? orderId;
  NotificationData._({required this.type, this.orderId});

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    try {
      // بناءً على الـ payload الجديد، تأكد من مفتاح نوع الإشعار (مثلاً notification_type)
      switch (map['notification_type'] as String?) {
        case '1':
          return NotificationData._(
            type: NotificationType.trackOrder,
            orderId: int.tryParse(map['order_id']?.toString() ?? ''),
          );
        default:
          return NotificationData._(type: NotificationType.unknown);
      }
    } catch (e) {
      return NotificationData._(type: NotificationType.unknown);
    }
  }
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final data = message.data;
  final notification = message.notification;

  // 1. تحديد لغة الجهاز الحالية
  // نستخدم PlatformDispatcher لأنه يعمل حتى لو التطبيق في الخلفية/مغلق
  String languageCode = ui.PlatformDispatcher.instance.locale.languageCode;

  // 2. اختيار العنوان والمحتوى بناءً على اللغة المرسلة في الـ data
  String title = '';
  String body = '';

  if (languageCode == 'ar') {
    title = data['title_ar'] ?? notification?.title ?? "إشعار جديد";
    body = data['message_ar'] ?? notification?.body ?? "";
  } else {
    title = data['title_en'] ?? notification?.title ?? "New Notification";
    body = data['message_en'] ?? notification?.body ?? "";
  }

  final payload = jsonEncode(data);

  await _localNotifications.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance',
        'High Importance',
        channelDescription: 'Important notifications',
        sound: RawResourceAndroidNotificationSound('custom_sound'),
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(sound: 'custom_sound.caf'),
    ),
    payload: payload,
  );
}

void handleNotificationTap(Map<String, dynamic> data) {
  log('Handling notification tap with data: $data');

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    int retryCount = 0;
    while (navigatorKey.currentState == null && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }

    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      final notificationData = NotificationData.fromMap(data);
      _performNavigation(notificationData);
    }
  });
}

void _performNavigation(NotificationData data) {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;

  log('Navigating to LayoutScreen from notification...');
  // الانتقال للرئيسية ومسح كل ما قبلها
  NavigatorMethods.pushNamedAndRemoveUntil(ctx, LayoutScreen.routeName);
}

class MessagingService {
  MessagingService._();

  static Future<void> init({
    required GlobalKey<NavigatorState> navKey,
  }) async {
    navigatorKey = navKey;
    await Firebase.initializeApp();
    await _createAndroidChannel();

    // 1. تهيئة الإشعارات المحلية
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

    // 2. طلب التصاريح
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. التطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((msg) async {
      log('Foreground message received: Showing localized notification');
      await _showLocalNotification(msg);
    });

    // 4. الضغط من الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      log('Notification tapped (Background)');
      handleNotificationTap(msg.data);
    });

    // 5. الضغط والتطبيق مغلق تماماً (Terminated)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('Notification tapped (Terminated)');
      handleNotificationTap(initialMessage.data);
    }

    // 6. معالج الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
