import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';

class PasswordInputWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    final password = authCubit.passwordLogin;

    return CustomTextField(
      initialValue: password,
      title: "password".tr(),
      isPassword: true,
      onChanged: (value) {
        authCubit.updatePassword(value);
      },
    );
  }
}
