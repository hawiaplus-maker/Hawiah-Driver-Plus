import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';

class PersonProfileListTile extends StatelessWidget {
  final String title;
  final String logo;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isHaveLine;

  const PersonProfileListTile({
    Key? key,
    required this.title,
    required this.logo,
    required this.onTap,
    this.trailing,
    this.isHaveLine = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  logo,
                  height: 24.h,
                  width: 24.w,
                  color: AppColor.blackColor,
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyle.text14_400,
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15.sp,
                      color: AppColor.blackColor,
                    ),
              ],
            ),
          ),
          if (isHaveLine)
            Divider(
              color: Colors.grey.shade300,
              thickness: 0.5,
              height: 0,
            ),
        ],
      ),
    );
  }
}
