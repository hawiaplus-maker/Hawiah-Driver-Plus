import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-state.dart';

class RegisterButtonWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String type;
  const RegisterButtonWidget(
      {Key? key, required this.formKey, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return GlobalElevatedButton(
          isLoading: isLoading,
          label: "sign_up".tr(),
          onPressed: isLoading
              ? null
              : () {
                  final authCubit = AuthCubit.get(context);

                  if (!authCubit.checkedValueTerms) {
                    Fluttertoast.showToast(
                      msg: tr(AppLocaleKey.mustAgreeToTerms),
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return;
                  }

                  if (formKey.currentState!.validate()) {
                    final cleanedPhone =
                        authCubit.formatPhoneNumber(authCubit.phoneNumber);

                    authCubit.register(
                      phoneNumber: authCubit.phoneControllerRegister.text,
                      type: type,
                    );
                  }
                },
          backgroundColor: AppColor.selectedLightBlueColor,
          textColor: AppColor.mainAppColor,
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          borderRadius: BorderRadius.circular(10),
          fixedWidth: 0.9,
        );
      },
    );
  }
}
