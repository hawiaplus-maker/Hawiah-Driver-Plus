import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';

class FooterRegisterWidget extends StatelessWidget {
  const FooterRegisterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "already_have_an_account".tr(),
          style: TextStyle(color: Color(0xff717177), fontSize: 16.sp),
        ),
        SizedBox(
          width: 5.w,
        ),
        GestureDetector(
          onTap: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigator.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          },
          child: Text(
            "login".tr(),
            style: TextStyle(color: AppColor.mainAppColor, fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}
