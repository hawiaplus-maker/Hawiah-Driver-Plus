// OnBoarding Page View
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';

class OnBoardingPageView extends StatelessWidget {
  final List<String> onBoardingImages;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const OnBoardingPageView({
    required this.onBoardingImages,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: onBoardingImages.length,
        itemBuilder: (context, index) {
          return CustomNetworkImage(
            imageUrl: onBoardingImages[index],
            height: 324.h,
            width: 324.w,
            fit: BoxFit.fill,
          );
        },
      ),
    );
  }
}
