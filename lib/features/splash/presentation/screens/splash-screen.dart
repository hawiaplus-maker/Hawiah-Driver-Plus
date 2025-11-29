import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/app-language/presentation/screens/app-language-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/controllers/on-boarding-cubit/on-boarding-cubit.dart';
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

    await Future.delayed(const Duration(seconds: 2));

    if (HiveMethods.isFirstTime() == true) {
      OnBoardingCubit.get(context).getOnboarding();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppLanguageScreen()),
      );
    } else {
      if (HiveMethods.getToken() != null) {
        await cubit.fetchProfile(
          onSuccess: () async {
            log("Navigation to LayoutScreen");
            if (!mounted) return;
            NavigatorMethods.pushReplacementNamed(
              context,
              LayoutScreen.routeName,
            );
          },
          onError: () {
            log("Navigation to AppLanguageScreen");
          },
        );
      } else {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
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
            child: Center(
              child: Image.asset(
                AppImages.hawiahPlus,
                height: 500,
                width: 500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
