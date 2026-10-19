import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/app_theme.dart';
import 'package:hawiah_driver/core/bloc-config/bloc_providers.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/notifications/messaging_config.dart';
import 'package:hawiah_driver/core/routes/app_routers_import.dart';
import 'package:hawiah_driver/features/app-language/presentation/widgets/locale_initializer.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/splash/presentation/screens/splash-screen.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:hawiah_driver/main.dart';

class HawiahPlusDriverApp extends StatefulWidget {
  const HawiahPlusDriverApp({super.key});

  static void setMyAppState(BuildContext context) async {
    _HawiahPlusDriverAppState? state = context.findAncestorStateOfType<_HawiahPlusDriverAppState>();
    state?.setMyAppState();
  }

  @override
  State<HawiahPlusDriverApp> createState() => _HawiahPlusDriverAppState();
}

class _HawiahPlusDriverAppState extends State<HawiahPlusDriverApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMessaging();
    });
    _appToken();
    super.initState();
  }

  void setMyAppState() {
    setState(() {});
  }

  void _initializeMessaging() async {
    try {
      await MessagingService.init(navKey: AppRouters.navigatorKey);
    } catch (e) {
      log('Messaging init failed: $e');
    }
  }

  void _appToken() async {
    final token = HiveMethods.getToken() ?? "No Token";
    log('App Token : $token');
    log("app lang is ==== ${HiveMethods.getLang()}" "lang");
  }

  @override
  Widget build(BuildContext context) {
    genContext = AppRouters.navigatorKey.currentContext ?? context;
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(381, 828),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MultiBlocProvider(
          providers: BlocProviders.blocs(),
          child: LocaleInitializer(
            child: MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              title: 'Hawiah Client',
              // You can use the library anywhere in the app even in theme
              theme: appTHeme(),
              home: child,
              builder: BotToastInit(),
              navigatorObservers: [BotToastNavigatorObserver()],
              onGenerateRoute: AppRouters.onGenerateRoute,
              navigatorKey: AppRouters.navigatorKey,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
            ),
          ),
        );
      },
      child: BlocProvider(
        create: (context) => sl<ProfileCubit>(),
        child: SplashScreen(),
      ),
    );
  }
}
