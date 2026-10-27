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

  /// Clears everything that belongs to the current session.
  ///
  /// Used on logout and whenever the server reports that the account may no
  /// longer use the app, so a stale token or work mode can't leak into the
  /// next session.
  static void clearSession() {
    deleteToken();
    deleteUserId();
    deleteWorkTypes();
    updateIsVisitor(true);
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
  //
  // The API sometimes sends them as `true`/`false`, sometimes as `1`/`0` or
  // `"true"`/`"false"`. Normalizing here keeps a raw value from silently
  // switching the driver back to the regular orders flow.
  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value == null) return null;
    switch (value.toString().trim().toLowerCase()) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default:
        return null;
    }
  }

  static bool? getOrderWork() => _toBool(_box.get('order_work'));

  static void updateOrderWork(dynamic value) {
    final parsed = _toBool(value);
    if (parsed == null) {
      _box.delete('order_work');
    } else {
      _box.put('order_work', parsed);
    }
  }

  static bool? getProjectWork() => _toBool(_box.get('project_work'));

  static void updateProjectWork(dynamic value) {
    final parsed = _toBool(value);
    if (parsed == null) {
      _box.delete('project_work');
    } else {
      _box.put('project_work', parsed);
    }
  }

  static bool? getCleaningContractWork() =>
      _toBool(_box.get('cleaning_contract_work'));

  static void updateCleaningContractWork(dynamic value) {
    final parsed = _toBool(value);
    if (parsed == null) {
      _box.delete('cleaning_contract_work');
    } else {
      _box.put('cleaning_contract_work', parsed);
    }
  }

  static void deleteWorkTypes() {
    _box.delete('order_work');
    _box.delete('project_work');
    _box.delete('cleaning_contract_work');
  }
}
