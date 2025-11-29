import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/injection_container.dart';

class ProfileInjection {
  static void init() {
    //cubit

    sl.registerLazySingleton<ProfileCubit>(() => ProfileCubit());

    //use cases

    //repository

    //data sources
  }
}
