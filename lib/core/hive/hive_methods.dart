import 'dart:ui';

import 'package:hive/hive.dart';

import '../theme/theme_enum.dart';

class HiveMethods {
  static String getDeviceLanguage() {
    return PlatformDispatcher.instance.locale.languageCode;
  }

  static final _box = Hive.box('app');

  static String getLang() {
    return _box.get('lang', defaultValue: getDeviceLanguage());
  }

  static void updateLang(Locale locale) {
    _box.put('lang', locale.languageCode);
  }

  static String? getToken() {
    return _box.get('token');
  }

  static void updateToken(String token) {
    _box.put('token', token);
  }

  static void deleteToken() {
    _box.delete('token');
  }

  static int? getUserId() {
    return _box.get('userId');
  }

  static void updateUserId(int? userId) {
    _box.put('userId', userId);
  }

  static void deleteUserId() {
    _box.delete('userId');
  }

  static bool isFirstTime() {
    return _box.get('isFirstTime', defaultValue: true);
  }

  static void updateFirstTime() {
    _box.put('isFirstTime', false);
  }

  static ThemeEnum getTheme() {
    return _box.get(
      'theme',
      defaultValue: ThemeEnum.light,
    );
  }

  static void updateThem(ThemeEnum theme) {
    _box.put('theme', theme);
  }

  static bool isVisitor() {
    return _box.get('isVisitor', defaultValue: false);
  }

  static void updateIsVisitor(bool? isVisitor) {
    _box.put('isVisitor', isVisitor);
  }
}
