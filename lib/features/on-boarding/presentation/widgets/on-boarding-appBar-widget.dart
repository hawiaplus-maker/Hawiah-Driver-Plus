import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';

import '../controllers/on-boarding-cubit/on-boarding-cubit.dart';

class OnBoardingAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OnBoardingCubit>();
    final isLastPage = cubit.currentIndex == (cubit.onBoardingList.length - 1);
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, top: 100, bottom: 40),
      child: isLastPage
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () {
                context.read<OnBoardingCubit>().skipPage();
              },
              child: Text(
                "skip".tr(),
                style: AppTextStyle.text18_400.copyWith(fontSize: 20.sp),
              ),
            ),
    );
  }
}
