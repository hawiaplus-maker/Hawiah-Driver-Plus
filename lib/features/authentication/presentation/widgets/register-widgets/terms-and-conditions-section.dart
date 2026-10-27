import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/bottom_sheet/privacy_bottom_sheet.dart';
import 'package:hawiah_driver/features/authentication/presentation/bottom_sheet/terms_bottom_sheet.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';

class TermsAndConditionsSection extends StatefulWidget {
  final bool checkedValueTerms;
  final Function(bool?) onCheckboxChanged;

  TermsAndConditionsSection({
    required this.checkedValueTerms,
    required this.onCheckboxChanged,
  });

  @override
  State<TermsAndConditionsSection> createState() =>
      _TermsAndConditionsSectionState();
}

class _TermsAndConditionsSectionState extends State<TermsAndConditionsSection> {
  @override
  void initState() {
    context.read<SettingCubit>().initialSetting();
    context.read<SettingCubit>().getsetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: context.read<SettingCubit>(),
        builder: (context, state) {
          final setting = context.read<SettingCubit>().setting;
          return GestureDetector(
            onTap: () {
              widget.onCheckboxChanged(!widget.checkedValueTerms);
            },
            child: Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  activeColor: Colors.green,
                  value: widget.checkedValueTerms,
                  shape: CircleBorder(),
                  onChanged: widget.onCheckboxChanged,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Color(0xff979797),
                        fontSize: 12.sp,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: "subscribe_agreement_text".tr()),
                        TextSpan(
                          text: "terms_and_conditions_text".tr(),
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              NavigatorMethods.showAppBottomSheet(
                                  context,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  TermsBottomSheet(
                                    terms: context.locale.languageCode == 'ar'
                                        ? setting?.termsCondition?.ar ?? ""
                                        : setting?.termsCondition?.en ?? "",
                                  ));
                            },
                        ),
                        TextSpan(text: "agreement_connector".tr()),
                        TextSpan(
                          text: "privacy_policy_text".tr(),
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              NavigatorMethods.showAppBottomSheet(
                                  context,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  PrivacyBottomSheet(
                                    privacy: context.locale.languageCode == 'ar'
                                        ? setting?.privacy?.ar ?? ""
                                        : setting?.privacy?.en ?? "",
                                  ));
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
