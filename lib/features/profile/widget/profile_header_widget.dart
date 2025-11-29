import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_profile_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfileModel user;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Column(
        children: [
          SizedBox(height: 30.h),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.mainAppColor, width: 1.5),
            ),
            child: CustomNetworkImage(
              radius: 50.r,
              fit: BoxFit.fill,
              imageUrl: user.image,
              height: 70.h,
              width: 70.w,
            ),
          ),
          SizedBox(width: 30.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                user.name,
                style: AppTextStyle.text20_500.copyWith(color: AppColor.mainAppColor),
              ),
              Gap(10.h),
              Text(
                textAlign: TextAlign.center,
                user.mobile,
                style: AppTextStyle.text16_400.copyWith(color: AppColor.textGrayColor),
              ),
            ],
          ),
          // GestureDetector(
          //   onTap: () {
          //     isGuest
          //         ? CommonMethods.showLoginFirstDialog(
          //             context,
          //             onPressed: () {
          //               Navigator.pop(context);
          //               NavigatorMethods.pushNamedAndRemoveUntil(context, LoginScreen.routeName);
          //             },
          //           )
          //         : Navigator.push(
          //             context,
          //             MaterialPageRoute(builder: (_) => UserProfile()),
          //           );
          //   },
          //   child: Row(
          //     children: [
          //       Image.asset(AppImages.editIcon,
          //           height: 15.h, width: 15.w, color: AppColor.mainAppColor),
          //       SizedBox(width: 5.w),
          //       Text(
          //         AppLocaleKey.edit.tr(),
          //         style: TextStyle(
          //           fontSize: 16.sp,
          //           color: AppColor.mainAppColor,
          //           decoration: TextDecoration.underline,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
