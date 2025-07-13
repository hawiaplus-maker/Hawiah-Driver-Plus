import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/bloc-config/bloc_observer.dart';
import 'package:hawiah_driver/core/bloc-config/bloc_providers.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/routes/app_routers_import.dart';
import 'package:hawiah_driver/core/theme/cubit/app_theme_cubit.dart';
import 'package:hawiah_driver/features/splash/presentation/screens/splash-screen.dart';
import 'package:hawiah_driver/firebase_options.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:hive_flutter/hive_flutter.dart';

late BuildContext genContext;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  AppInjector.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('app');

  Bloc.observer = MyBlocObserver();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: Locale('ar'),
      fallbackLocale: const Locale(
        'en',
      ), // Add a fallback locale if you haven't
      child: BlocProvider(
        create: (context) => AppThemeCubit()..initial(),
        child: const MyApp(),
      ), // Wrap MyApp instead of PetCareHomeScreen
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setMyAppState(BuildContext context) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setMyAppState();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _appToken();
    super.initState();
  }

  void setMyAppState() {
    setState(() {});
  }

  void _appToken() async {
    final token = HiveMethods.getToken() ?? "No Token";
    log('App Token : $token');
    log(
      "app lang is ==== ${HiveMethods.getLang()}"
      "lang",
    );
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
          ),
        );
      },
      child: SplashScreen(),
    );
  }

  ThemeData appTHeme() {
    return ThemeData(
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(color: Colors.white),
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      primarySwatch: Colors.blue,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Default text style
        bodyMedium: TextStyle(color: Colors.black), // For smaller text
        displayLarge: TextStyle(color: Colors.black), // Headlines
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.grey[600], // Lighter grey color for hint text
          fontSize: 16, // A standard font size for hints
        ),
        labelStyle: TextStyle(
          color: Colors.black, // Label color (for fields with label)
          fontSize: 16, // Standard font size for labels
          fontWeight: FontWeight.w500, // Medium weight for clarity
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(
              0.6,
            ), // Slightly greyish black for border
            width: 1.5, // Slightly thicker border for better visibility
          ),
          borderRadius: BorderRadius.circular(
            12.0,
          ), // Rounded corners for modern look
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(
              0.6,
            ), // Slightly greyish black for disabled state
            width: 1.5, // Slightly thicker border for better visibility
          ),
          borderRadius: BorderRadius.circular(
            12.0,
          ), // Rounded corners for modern look
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue, // Blue color when the field is focused
            width: 2.0, // Thicker border when focused
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Red color for error state
            width: 2.0, // Slightly thicker for visibility
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Red color when focused and in error state
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        // Optional: Adding `contentPadding` to adjust space inside the field
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ), // More space for readability
      ),
    );
  }
}
