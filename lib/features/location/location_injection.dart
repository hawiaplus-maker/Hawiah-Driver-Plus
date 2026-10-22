
import 'package:hawiah_driver/features/location/presentation/cubit/address_cubit.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/injection_container.dart';

class AddressInjection {
  static void init() {
    //cubit

    sl.registerFactory(() => AddressCubit());

    //services

    // The location service holds the position detected when the app opens,
    // so it has to be shared by the whole app.
    sl.registerLazySingleton<LocationService>(() => LocationService());

    //use cases

    //repository

    //data sources
  }
}
