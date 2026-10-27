import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/utils/validation_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';

class RegisterPasswordInputWidget extends StatelessWidget {
  const RegisterPasswordInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);

    return CustomTextField(
      controller: authCubit.passwordControllerRegister,
      title: "password".tr(),
      hintText: "enter_your_password".tr(),
      isPassword: true,
      textInputAction: TextInputAction.done,
      validator: ValidationMethods.validatePassword,
    );
  }
}
