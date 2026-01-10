import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app-language-state.dart';

class AppLanguageCubit extends Cubit<AppLanguageState> {
  static AppLanguageCubit get(context) => BlocProvider.of(context);

  AppLanguageCubit() : super(AppLanguageInitial()) {
    loadSavedLanguage(); // تحميل اللغة المحفوظة عند إنشاء الكابت
  }

  String? languageSelected;

  List<String> languages = ["arabic", "english", "urdu"];

  changeLanguage({required String language}) async {
    languageSelected = language;

    emit(AppLanguageChange(languageSelected: language));
    switch (language) {
      case 'arabic':
        HiveMethods.updateLang(Locale('ar'));
        break;
      case 'english':
        HiveMethods.updateLang(Locale('en'));
        break;
      case 'urdu':
        HiveMethods.updateLang(Locale('ur'));
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
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
