import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/utils/country_code_methods.dart';
import 'package:hawiah_driver/core/utils/validation_methods.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';

class PhoneInputWidget extends StatelessWidget {
  const PhoneInputWidget({super.key, this.controller});
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    Country _country = CountryCodeMethods.getByCode('966');

    final authCubit = AuthCubit.get(context);

    return CustomTextField(
      validator: (v) => ValidationMethods.validatePhone(v, country: _country),
      controller: controller,
      title: "phone_number".tr(),
      // hintText: "phone_number".tr(),
      onChanged: (value) {
        authCubit.PhoneController.text = value;
      },
    );
  }
}
