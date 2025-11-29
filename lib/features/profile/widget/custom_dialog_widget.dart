import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String content;

  final String image;

  const CustomConfirmDialog({
    super.key,
    required this.content,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColor.whiteColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(
                  AppImages.closeCircleIcon,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            Image.asset(image, height: 80.h, width: 80.w),
            const SizedBox(height: 15),
            Text(
              content,
              textAlign: TextAlign.center,
              style: AppTextStyle.text20_500,
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
