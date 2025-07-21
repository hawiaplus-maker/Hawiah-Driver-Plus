import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/company-profile-completion-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/personal-profile-completion-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/reset-password-screen.dart';
import 'package:pinput/pinput.dart';

import '../controllers/auth-cubit/auth-cubit.dart';
import '../controllers/auth-cubit/auth-state.dart';

class VerificationOtpScreen extends StatefulWidget {
  const VerificationOtpScreen({Key? key, this.phoneNumber, this.otp})
    : super(key: key);

  final String? phoneNumber;
  final int? otp;
  @override
  _VerificationOtpScreenState createState() => _VerificationOtpScreenState();
}

class _VerificationOtpScreenState extends State<VerificationOtpScreen> {
  @override
  late TextEditingController otpController;
  void initState() {
    otpController = TextEditingController();
    context.read<AuthCubit>().startTimer();
    super.initState();
  }

  bool isOtpValid = false;
  @override
  void dispose() {
    otpController.dispose();
    context.read<AuthCubit>().timer.cancel();
    super.dispose();
  }
  // @override
  // void dispose() {
  //   if (mounted) {
  //     context.read<AuthCubit>().timer.cancel();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          int remainingTime = 30;
          bool isTimerCompleted = false;
          if (state is AuthTimerState) {
            remainingTime = state.remainingTime;
            isTimerCompleted = state.isTimerCompleted;
          }
          final authCubit = AuthCubit.get(context);
          final isResetPassword = authCubit.isResetPassword;
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "enterVerificationCode".tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "verificationCodeSentResetPassword".tr(),
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Directionality(
                    textDirection:
                        context.locale.languageCode == 'ar'
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        Text(
                          '${widget.phoneNumber}' ?? '+966 5 123 45678',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Image.asset(
                          "assets/images/refresh-cw-03.png",
                          fit: BoxFit.fill,
                          height: 18.w,
                          width: 18.h,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Directionality(
                    textDirection:
                        context.locale.languageCode == 'ar'
                            ? TextDirection.ltr
                            : TextDirection.ltr,
                    child: Center(
                      child: Pinput(
                        controller: otpController,
                        length: 5,
                        onChanged: (value) {
                          setState(() {
                            isOtpValid = value.length == 5;
                          });
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        defaultPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isOtpValid ? Colors.green : Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  authCubit.showInvalidCodeMessage
                      ? Center(
                        child: Text(
                          'كود غير صحيح، الرجاء المحاولة مرة أخرى',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      )
                      : Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'resend_code_message'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${authCubit.remainingTime < 10 ? "00:0${authCubit.remainingTime}" : "00:${authCubit.remainingTime}"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  SizedBox(height: 20),
                  Spacer(),
                  Center(
                    child: GlobalElevatedButton(
                      label: "resend_code".tr(),
                      onPressed:
                          authCubit.isTimerCompleted
                              ? () {
                                authCubit.resetInvalidCodeMessage();
                                authCubit.startTimer();
                                otpController.clear();
                                authCubit.resendCodeToApi(
                                  phoneNumber: widget.phoneNumber ?? "",
                                );
                              }
                              : null,
                      backgroundColor: AppColor.mainAppColor,
                      textColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      fixedWidth: 0.80,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GlobalElevatedButton(
                      label: "continue".tr(),
                      onPressed: () {
                        final otpText = otpController.text;
                        if (otpText.length == 5) {
                          AuthCubit.get(context).otp(
                            phoneNumber: widget.phoneNumber!,
                            otp: int.parse(otpText),
                          );
                        }
                      },
                      backgroundColor: Color(0xffEDEEFF),
                      textColor: AppColor.mainAppColor,
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
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.black,
              fontSize: 16.0,
            );
          }
          if (state is AuthSuccess) {
            final authCubit = AuthCubit.get(context);
            final isResetPassword = authCubit.isResetPassword;
            context.read<AuthCubit>().timer.cancel();

            if (isResetPassword) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ResetPasswordScreen(
                        phone: widget.phoneNumber ?? "",
                        otp: widget.otp ?? 0,
                      ),
                ),
              );
            } else {
              if (context.read<AuthCubit>().selectedAccountType == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PersonalProfileCompletionScreen(
                          phoneNumber: widget.phoneNumber ?? "",
                        ),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const CompanyProfileCompletionScreen(),
                  ),
                );
              }
            }
          } else if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else if (state is AuthCodeResentSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else if (state is AuthCodeResentError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
      ),
    );
  }
}
