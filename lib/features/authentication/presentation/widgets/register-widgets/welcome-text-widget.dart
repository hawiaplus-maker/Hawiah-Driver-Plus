import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomeTextWidget extends StatelessWidget {
  const WelcomeTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "welcomeToHawiah".tr(),
          style: TextStyle(fontSize: 25.sp, color: Colors.black),
        ),
        Text(
          "steps_to_register_new_account".tr(),
          style: TextStyle(fontSize: 15.sp, color: Color(0xff979797)),
        ),
      ],
    );
  }
}
