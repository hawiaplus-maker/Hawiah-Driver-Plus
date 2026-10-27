import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/app-language/presentation/screens/app-language-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/injection_container.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final settingCubit = sl<SettingCubit>();
    settingCubit.getsetting();
    log("is first time ${HiveMethods.isFirstTime()}");
    final cubit = sl<ProfileCubit>();

    // Ask for the location permission as soon as the app opens: the discharge
    // flow attaches the driver position, so it has to be granted before the
    // driver starts working. The position is then kept fresh by the service so
    // an action never waits for a GPS fix.
    await sl<LocationService>().initLocationTracking();
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 2));

    if (HiveMethods.isFirstTime() == true) {
      // OnBoardingCubit.get(context).getOnboarding();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppLanguageScreen()),
      );
    } else {
      // A token alone is not proof that the account can still use the app:
      // the account may have been deactivated while the token is still valid.
      // Every app start therefore validates the session through user-info and
      // only opens the app when the server confirms the account is active.
      if (HiveMethods.getToken() != null) {
        await cubit.fetchUserInfo(
          onSuccess: () async {
            log("Navigation to LayoutScreen");
            if (!mounted) return;
            NavigatorMethods.pushReplacementNamed(
              context,
              LayoutScreen.routeName,
            );
          },
          onDenied: (message) {
            log("Access denied: $message");
            if (!mounted) return;
            CommonMethods.showError(message: message);
            _goToLogin();
          },
          onError: (message) {
            log("Navigation to LoginScreen (Error): $message");
            _goToLogin();
          },
        );
      } else {
        _goToLogin();
      }
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Image.asset(
              AppImages.newAppLogoImage,
              height: 500,
              width: 500,
            ),
          ),
        ],
      ),
    );
  }
}
