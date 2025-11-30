abstract class AppLanguageState {}

class AppLanguageInitial extends AppLanguageState {}

class AppLanguageChange extends AppLanguageState {
  final String? languageSelected;
  AppLanguageChange({this.languageSelected});
}

class AppLanguageRebuild extends AppLanguageState {
  final String? languageSelected;
  AppLanguageRebuild({this.languageSelected});
}
