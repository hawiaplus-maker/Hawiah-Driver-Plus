import 'package:get_it/get_it.dart';
import 'package:hawiah_driver/features/app-language/app-language-injection.dart';
import 'package:hawiah_driver/features/authentication/authentication-injection.dart';
import 'package:hawiah_driver/features/chat/chat_injection.dart';
import 'package:hawiah_driver/features/layout/layout-injection.dart';
import 'package:hawiah_driver/features/notifications/notifications_injection.dart';
import 'package:hawiah_driver/features/on-boarding/on-boarding-injection.dart';
import 'package:hawiah_driver/features/profile/presentation/Profile_user_injection.dart';
import 'package:hawiah_driver/features/setting/setting_injection.dart';

import 'features/order/order-injection.dart';

GetIt sl = GetIt.instance;

class AppInjector {
  static Future<void> init() async {
    AppLanguageInjection.init();
    OnBoardingInjection.init();
    AuthenticationInjection.init();
    LayoutInjection.init();
    OrderInjection.init();
    SettingInjection.init();
    ProfileInjection.init();
    NotificationsInjection.init();
    
  }
}
