import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hawiah_driver/core/custom_widgets/app_bottom_sheet.dart';

class PrivacyBottomSheet extends StatelessWidget {
  const PrivacyBottomSheet({super.key, required this.privacy, this.isLine});
  final String privacy;
  final bool? isLine;
  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      isLine: isLine,
      title: "privacy_policy_text".tr(),
      children: [
        Html(
          data: privacy,
        ),
      ],
    );
  }
}
