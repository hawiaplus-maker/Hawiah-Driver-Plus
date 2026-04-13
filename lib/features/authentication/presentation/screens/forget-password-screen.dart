import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/global-phone-input-widget.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/verification-otp-screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import '../controllers/auth-cubit/auth-cubit.dart';
import '../controllers/auth-cubit/auth-state.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_forward_ios_sharp, color: Colors.grey),
              onPressed: () {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ]),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          final authCubit = AuthCubit.get(context);
          final fullNumberResetPassword = authCubit.fullNumberResetPassword;

          return Container(
            padding: EdgeInsets.all(10.w),
            child: Form(
              key: authCubit.formKeyRegister,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "forgot_password".tr(),
                          style:
                              TextStyle(fontSize: 25.sp, color: Colors.black),
                        ),
                        Text(
                          "setPasswordMessage".tr(),
                          style: TextStyle(
                              fontSize: 15.sp, color: Color(0xff979797)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GlobalPhoneInputWidget(
                    onPhoneNumberChange: (PhoneNumber number) {
                      authCubit.onPhoneNumberChange(number: number);
                    },

                    initialValue: fullNumberResetPassword,
                    isRtl: context.locale.languageCode == 'ar',
                    // Customizable hint text
                  ),
                  Spacer(),
                  GlobalElevatedButton(
                    label: "continue".tr(),
                    onPressed: () {
                      if (authCubit.formKeyRegister.currentState!.validate()) {
                        final cleanedPhone = authCubit.formatPhoneNumber(authCubit.phoneNumber);
                        authCubit.forgotPassword(
                          phoneNumber: cleanedPhone,
                        );
                      }
                    },
                    backgroundColor: AppColor.mainAppColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    borderRadius: BorderRadius.circular(10),
                    fixedWidth: 0.80, // 80% width of the screen
                  ),
                  SizedBox(height: 20.h),
                ],
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
          if (state is AuthForgotPasswordSuccess) {
            AuthCubit.get(context).isResetPassword = true;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerificationOtpScreen(
                          phoneNumber: state.data?['mobile'],
                          otp: state.data?['otp'],
                        )));
          }
        },
      ),
    );
  }
}
