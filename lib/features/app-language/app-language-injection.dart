import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';
import 'package:hawiah_driver/injection_container.dart';

class AppLanguageInjection {
  static void init() {
    //cubit

    sl.registerFactory(() => AppLanguageCubit());

    //use cases

    //repository

    //data sources
  }
}
