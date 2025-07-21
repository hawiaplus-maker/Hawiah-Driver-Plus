import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';

void showThankYouBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text(
              AppLocaleKey.valuableTime.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              AppLocaleKey.improveOurServices.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            GlobalElevatedButton(
              label: AppLocaleKey.confirm.tr(),
              onPressed: () {},
              backgroundColor: AppColor.mainAppColor,
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              borderRadius: BorderRadius.circular(10),
              fixedWidth: 0.80, // 80% of the screen width
            ),
            SizedBox(height: 16),
            GlobalElevatedButton(
              label: AppLocaleKey.askMeAgain.tr(),
              onPressed: () {},
              backgroundColor: Colors.white,
              textColor: Colors.red.shade300,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              borderRadius: BorderRadius.circular(20),
              fixedWidth: 0.80, // 80% of the screen width
            ),
          ],
        ),
      );
    },
  );
}
