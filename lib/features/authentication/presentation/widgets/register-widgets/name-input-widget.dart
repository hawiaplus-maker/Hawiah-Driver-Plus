import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/utils/validation_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';

class NameInputWidget extends StatelessWidget {
  const NameInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);

    return CustomTextField(
      controller: authCubit.nameControllerRegister,
      title: "name".tr(),
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      validator: ValidationMethods.validateName,
    );
  }
}
