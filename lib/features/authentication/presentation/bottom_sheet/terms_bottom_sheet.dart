import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hawiah_driver/core/custom_widgets/app_bottom_sheet.dart';

class TermsBottomSheet extends StatelessWidget {
  const TermsBottomSheet({super.key, required this.terms});
  final String terms;
  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: "terms_and_conditions_text".tr(),
      children: [
        Html(
          data: terms,
        ),
      ],
    );
  }
}
