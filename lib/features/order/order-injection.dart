import 'package:hawiah_driver/injection_container.dart';

import 'presentation/order-cubit/order-cubit.dart';

class OrderInjection {
  static void init() {
    //cubit

    sl.registerLazySingleton(() => OrderCubit());

    //use cases

    //repository

    //data sources
  }
}
