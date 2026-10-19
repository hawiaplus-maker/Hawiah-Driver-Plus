import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app-language-state.dart';

class AppLanguageCubit extends Cubit<AppLanguageState> {
  static AppLanguageCubit get(context) => BlocProvider.of(context);

  AppLanguageCubit() : super(AppLanguageInitial()) {
    loadSavedLanguage();
  }

  String? languageSelected;

  List<String> languages = ["arabic", "english", "urdu"];

  /// Initialize the locale from saved preferences
  /// This should be called with a valid BuildContext after the widget tree is built
  Future<void> initializeLocale(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_language');
    if (savedLang != null) {
      languageSelected = savedLang;
      Locale locale;
      switch (savedLang) {
        case 'arabic':
          locale = const Locale('ar');
          break;
        case 'english':
          locale = const Locale('en');
          break;
        case 'urdu':
          locale = const Locale('ur');
          break;
        default:
          locale = const Locale('en');
      }
      HiveMethods.updateLang(locale);
      await context.setLocale(locale);
      emit(AppLanguageChange(languageSelected: savedLang));
    }
  }

  changeLanguage({required String language, BuildContext? context}) async {
    languageSelected = language;

    emit(AppLanguageChange(languageSelected: language));
    Locale locale;
    switch (language) {
      case 'arabic':
        locale = const Locale('ar');
        HiveMethods.updateLang(locale);
        break;
      case 'english':
        locale = const Locale('en');
        HiveMethods.updateLang(locale);
        break;
      case 'urdu':
        locale = const Locale('ur');
        HiveMethods.updateLang(locale);
        break;
      default:
        locale = const Locale('en');
        HiveMethods.updateLang(locale);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    
    if (context != null && context.mounted) {
      await context.setLocale(locale);
    }
  }

  changeRebuild() {
    emit(AppLanguageRebuild(languageSelected: languageSelected));
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('selected_language');
    if (savedLang != null) {
      languageSelected = savedLang;
      emit(AppLanguageChange(languageSelected: savedLang));
    }
  }
}
