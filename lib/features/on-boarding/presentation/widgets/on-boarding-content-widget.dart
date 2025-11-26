import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';

class OnBoardingContent extends StatelessWidget {
  final int currentIndex;
  final List<String> onboardingIcons;
  final List<String> onboardingTitles;
  final List<String> onboardingContents;
  final double progressValue;
  final PageController pageController;
  final int totalImagesCount;

  const OnBoardingContent({
    required this.currentIndex,
    required this.onboardingIcons,
    required this.onboardingTitles,
    required this.onboardingContents,
    required this.progressValue,
    required this.pageController,
    required this.totalImagesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              textAlign: TextAlign.center,
              onboardingTitles[currentIndex],
              style: AppTextStyle.text24_700,
            ),
          ),
          Gap(10.h),
          Center(
            child: Text(
              textAlign: TextAlign.center,
              onboardingContents[currentIndex],
              style: AppTextStyle.text20_500.copyWith(color: AppColor.textGrayColor),
            ),
          ),
          SizedBox(height: 20.h),
          currentIndex != totalImagesCount - 1
              ? CustomButton(
                  text: "next".tr(),
                  onPressed: () {
                    print(totalImagesCount);
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              : CustomButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  text: "Letsgetstarted".tr(),
                ),
          Gap(50.h)
        ],
      ),
    );
  }
}
