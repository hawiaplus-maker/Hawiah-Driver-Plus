import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';

class CompanyStepOne extends StatelessWidget {
  final String nameCompleteProfile;
  final String emailCompleteProfile;
  final String passwordCompleteProfile;
  final String confirmPasswordCompleteProfile;
  final bool passwordVisibleCompleteProfile;
  final List<String> accountTypesCompleteProfile;
  final String? selectedAccountTypeCompleteProfile;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final ValueChanged<String?> onAccountTypeChanged;

  const CompanyStepOne({
    Key? key,
    required this.nameCompleteProfile,
    required this.emailCompleteProfile,
    required this.passwordCompleteProfile,
    required this.confirmPasswordCompleteProfile,
    required this.passwordVisibleCompleteProfile,
    required this.accountTypesCompleteProfile,
    required this.selectedAccountTypeCompleteProfile,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onAccountTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          labelText: "cream_name".tr(),
          hintText: "cream_name".tr(),
          initialValue: nameCompleteProfile,
          onChanged: onNameChanged,
        ),
        SizedBox(height: 20),
        CustomTextField(
          labelText: "email".tr(),
          hintText: "email".tr(),
          initialValue: emailCompleteProfile,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        SizedBox(height: 20),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: "company".tr()),
          initialValue: selectedAccountTypeCompleteProfile ?? accountTypesCompleteProfile[0],
          items: accountTypesCompleteProfile.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type.tr()),
            );
          }).toList(),
          onChanged: onAccountTypeChanged,
        ),
        SizedBox(height: 20),
        CustomTextField(
          labelText: 'password'.tr(),
          hintText: 'enter_your_password'.tr(),
          initialValue: passwordCompleteProfile,
          suffixIcon: IconButton(
            icon: Image.asset(
              passwordVisibleCompleteProfile
                  ? 'assets/icons/eye_password_icon.png'
                  : 'assets/icons/eye_hide_password_icon.png',
              color: Theme.of(context).primaryColorDark,
              height: 24.0,
              width: 24.0,
            ),
            onPressed: () {
              // Handle password visibility toggle
            },
          ),
          onChanged: onPasswordChanged,
        ),
        SizedBox(height: 20),
        CustomTextField(
          labelText: 'confirm_password'.tr(),
          hintText: 'enter_your_password'.tr(),
          initialValue: confirmPasswordCompleteProfile,
          suffixIcon: IconButton(
            icon: Image.asset(
              passwordVisibleCompleteProfile
                  ? 'assets/icons/eye_password_icon.png'
                  : 'assets/icons/eye_hide_password_icon.png',
              color: Theme.of(context).primaryColorDark,
              height: 24.0,
              width: 24.0,
            ),
            onPressed: () {
              // Handle password visibility toggle
            },
          ),
          onChanged: onConfirmPasswordChanged,
        ),
        SizedBox(height: 0.10.sh),
      ],
    );
  }
}
