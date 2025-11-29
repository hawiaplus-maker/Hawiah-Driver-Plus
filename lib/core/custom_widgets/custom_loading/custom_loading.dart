import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomLoading extends StatelessWidget {
  final double size;
  final Color? color;
  const CustomLoading({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        colors: [color ?? AppColor.mainAppColor],
        strokeWidth: 2,
      ),
    );
  }
}
