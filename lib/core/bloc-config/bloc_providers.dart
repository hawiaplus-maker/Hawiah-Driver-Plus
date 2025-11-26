import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';
import 'package:hawiah_driver/features/location/presentation/cubit/address_cubit.dart';
import 'package:hawiah_driver/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/controllers/on-boarding-cubit/on-boarding-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/injection_container.dart';

class BlocProviders {
  static List<BlocProvider> blocs() {
    return <BlocProvider>[
      BlocProvider<AppLanguageCubit>(
        create: (context) => sl<AppLanguageCubit>(),
      ),
      BlocProvider<OnBoardingCubit>(create: (context) => sl<OnBoardingCubit>()),
      BlocProvider<AuthCubit>(create: (context) => sl<AuthCubit>()),
      BlocProvider<OrderCubit>(create: (context) => sl<OrderCubit>()),
      BlocProvider<OrderCubit>(create: (context) => sl<OrderCubit>()),
      BlocProvider<SettingCubit>(create: (context) => sl<SettingCubit>()),
      BlocProvider<ProfileCubit>(create: (context) => sl<ProfileCubit>()),
      BlocProvider<AddressCubit>(create: (context) => sl<AddressCubit>()),
      BlocProvider<NotificationsCubit>(
        create: (context) => sl<NotificationsCubit>(),
      ),
    ];
  }
}
