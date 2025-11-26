import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/validate_mobile_screen.dart';

class UnauthenticatedDialog extends StatelessWidget {
  const UnauthenticatedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.whiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () => Navigator.pop(context),
                  icon: SvgPicture.asset(AppImages.closeCircleIcon)),
            ],
          ),
          Image.asset(
            AppImages.unauthenticatedImage,
            height: 100,
          ),
          Text(
            AppLocaleKey.notRegisteredYet.tr(),
            style: AppTextStyle.text16_700,
          ),
          Text(AppLocaleKey.toBrowseServicesRegisterNow.tr(),
              style: AppTextStyle.textG16_500.copyWith(fontSize: 14)),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
            child: CustomButton(
              height: 40,
              text: "login".tr(),
              style: AppTextStyle.buttonStyle.copyWith(color: AppColor.whiteColor, fontSize: 16),
              onPressed: () {
                NavigatorMethods.pushNamedAndRemoveUntil(context, ValidateMobileScreen.routeName);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
            child: CustomButton(
              color: AppColor.secondAppColor,
              height: 40,
              text: AppLocaleKey.cancel.tr(),
              style: AppTextStyle.buttonStyle.copyWith(color: AppColor.whiteColor, fontSize: 16),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
