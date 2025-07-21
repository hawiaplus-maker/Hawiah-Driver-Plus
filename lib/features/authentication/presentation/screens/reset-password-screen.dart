import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';

import '../controllers/auth-cubit/auth-cubit.dart';
import '../controllers/auth-cubit/auth-state.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.otp,
  });
  final String phone;
  final int otp;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          final authCubit = AuthCubit.get(context);
          context.read<AuthCubit>().timer.cancel();
          String passwordReset = authCubit.passwordReset;

          String passwordConfirmReset = authCubit.passwordConfirmReset;
          bool passwordVisibleReset = authCubit.passwordVisibleReset;
          final listPasswordCriteria = authCubit.listPasswordCriteria;
          return SizedBox(
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(right: 25.w, top: 60.h, left: 25.w),
              child: Form(
                key: authCubit.formKeyCompleteProfile,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "createNewPassword".tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "enterSecurePassword".tr(),
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'كلمة المرور لا يمكن أن تكون فارغة';
                        }
                        if (value.length < 8) {
                          return 'كلمة المرور يجب ألا تقل عن 8 أحرف';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
                        }
                        if (!RegExp(r'[!@#\$&*~%^-_=+<>?]').hasMatch(value)) {
                          return 'كلمة المرور يجب أن تحتوي على رمز مثل @ أو # أو !';
                        }
                        return null;
                      },
                      controller: authCubit.passwordController,
                      labelText: 'password'.tr(),
                      hintText: 'enter_your_password'.tr(),
                      // obscureText: !passwordVisibleReset,
                      // hasSuffixIcon: true,
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          passwordVisibleReset
                              ? 'assets/icons/view.png'
                              : 'assets/icons/eye_hide_password_icon.png',
                          color: Theme.of(context).primaryColorDark,
                          height: 24.0,
                          width: 24.0,
                        ),
                        onPressed: () {
                          authCubit.togglePasswordVisibilityReset();
                        },
                      ),
                      onChanged: (value) {
                        passwordReset = value;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'password_required'.tr();
                        }
                        if (value.length < 8) {
                          return 'password_min_length'.tr();
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'password_number_required'.tr();
                        }
                        if (!RegExp(r'[!@#\$&*~%^-_=+<>?]').hasMatch(value)) {
                          return 'password_symbol_required'.tr();
                        }
                        return null;
                      },

                      controller: authCubit.confirmPasswordController,
                      labelText: 'confirm_password'.tr(),
                      hintText: 'enter_your_password'.tr(),
                      // obscureText: !passwordVisibleReset,
                      // hasSuffixIcon: true,
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          passwordVisibleReset
                              ? 'assets/icons/view.png'
                              : 'assets/icons/eye_hide_password_icon.png',
                          color: Theme.of(context).primaryColorDark,
                          height: 24.0,
                          width: 24.0,
                        ),
                        onPressed: () {
                          authCubit.togglePasswordVisibilityReset();
                        },
                      ),
                      onChanged: (value) {
                        passwordConfirmReset = value;
                      },
                    ),
                    Spacer(),
                    SizedBox(height: 20),
                    Center(
                      child: GlobalElevatedButton(
                        label: "continue".tr(),
                        onPressed: () {
                          final password =
                              authCubit.passwordController.text.trim();
                          final confirmPassword =
                              authCubit.confirmPasswordController.text.trim();

                          if (authCubit.formKeyCompleteProfile.currentState!
                              .validate()) {
                            if (password != confirmPassword) {
                              Fluttertoast.showToast(
                                msg: "كلمة المرور وتأكيدها غير متطابقين",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }

                            authCubit.resetPassword(
                              password: password,
                              password_confirmation: confirmPassword,
                              phoneNumber: phone,
                              otp: otp,
                            );
                          }
                        },
                        backgroundColor: Color(0xffEDEEFF),
                        textColor:
                            authCubit.passwordController.text.isNotEmpty &&
                                    authCubit
                                        .confirmPasswordController
                                        .text
                                        .isNotEmpty
                                ? AppColor.mainAppColor
                                : AppColor.mainAppColor.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        fixedWidth: 0.80, // 80% of the screen width
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }

          if (state is AuthSuccess) {
            if (context.mounted) {
              context.read<AuthCubit>().timer.cancel();
            }

            Future.microtask(() {
              if (context.mounted) {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            });
          }
        },
      ),
    );
  }
}
