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

  // ===== Work type flags (order_work / project_work / cleaning_contract_work) =====
  // Persisted in Hive because AuthCubit is registered as a factory, so instance
  // fields don't survive; these flags must be readable anywhere (e.g. OrderCubit).
  static bool? getOrderWork() {
    final value = _box.get('order_work');
    return value is bool ? value : null;
  }

  static void updateOrderWork(bool? value) {
    if (value == null) {
      _box.delete('order_work');
    } else {
      _box.put('order_work', value);
    }
  }

  static bool? getProjectWork() {
    final value = _box.get('project_work');
    return value is bool ? value : null;
  }

  static void updateProjectWork(bool? value) {
    if (value == null) {
      _box.delete('project_work');
    } else {
      _box.put('project_work', value);
    }
  }

  static bool? getCleaningContractWork() {
    final value = _box.get('cleaning_contract_work');
    return value is bool ? value : null;
  }

  static void updateCleaningContractWork(bool? value) {
    if (value == null) {
      _box.delete('cleaning_contract_work');
    } else {
      _box.put('cleaning_contract_work', value);
    }
  }

  static void deleteWorkTypes() {
    _box.delete('order_work');
    _box.delete('project_work');
    _box.delete('cleaning_contract_work');
  }
}
