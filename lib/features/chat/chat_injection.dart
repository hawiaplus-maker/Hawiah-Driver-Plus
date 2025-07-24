





import 'package:hawiah_driver/features/chat/cubit/chat_cubit.dart';
import 'package:hawiah_driver/injection_container.dart';

class ChatInjection {
  static void init() {
    //cubit

    sl.registerFactory(() => ChatCubit());

    //use cases

    //repository

    //data sources
  }
}
