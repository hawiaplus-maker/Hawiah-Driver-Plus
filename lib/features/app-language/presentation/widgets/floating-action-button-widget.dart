import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/screens/on-borading-screen.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      elevation: 0.0,
      backgroundColor: AppColor.mainAppColor,
      onPressed: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const OnBoardingScreen(),
          ),
        );
        // if (HiveMethods.isFirstTime()) {

        // } else {
        //   Navigator.pushAndRemoveUntil<void>(
        //     context,
        //     MaterialPageRoute<void>(
        //       builder: (BuildContext context) => const LoginScreen(),
        //     ),
        //     (route) => false,
        //   );
        // }
      },
      child: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }
}
