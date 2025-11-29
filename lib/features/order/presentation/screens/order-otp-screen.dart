import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_toast.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/features/order/presentation/screens/confirmation_screen.dart';
import 'package:pinput/pinput.dart';

class OrderOtpScreen extends StatefulWidget {
  const OrderOtpScreen({Key? key, required this.id, required this.otp}) : super(key: key);
  final String otp;
  final int? id;
  @override
  _OrderOtpScreenState createState() => _OrderOtpScreenState();
}

class _OrderOtpScreenState extends State<OrderOtpScreen> {
  @override
  late TextEditingController otpController;
  void initState() {
    otpController = TextEditingController();
    super.initState();
  }

  bool isOtpValid = false;
  @override
  void dispose() {
    otpController.dispose();
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "enterVerificationCode".tr(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppLocaleKey.investigationCode.tr(),
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SvgPicture.asset(
                  AppImages.otpIcon,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              ),
              SizedBox(height: 30),
              Directionality(
                textDirection:
                    context.locale.languageCode == 'ar' ? TextDirection.ltr : TextDirection.ltr,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Pinput(
                    controller: otpController,
                    length: 4,
                    separatorBuilder: (index) => const SizedBox(width: 30),
                    showCursor: true,
                    cursor: Container(
                      width: 2,
                      height: 28,
                      color: AppColor.mainAppColor,
                    ),
                    defaultPinTheme: PinTheme(
                      width: 40,
                      height: 60,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                    preFilledWidget: Center(
                      child: Text(
                        '---',
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -3),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 40,
                      height: 60,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 40,
                      height: 60,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                    onCompleted: (value) {
                      final otpText = otpController.text;
                      isOtpValid = widget.otp == otpText;
                      (isOtpValid)
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmationScreen(
                                  otp: widget.otp,
                                  id: widget.id,
                                ),
                              ),
                            )
                          : CommonMethods.showToast(
                              message: 'not valid otp', type: ToastType.error);
                    },
                  ),
                ),
              ),
              Spacer(),
              SizedBox(height: 20),
              CustomButton(
                text: "continue".tr(),
                onPressed: () {
                  (isOtpValid)
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmationScreen(
                              otp: widget.otp,
                              id: widget.id,
                            ),
                          ),
                        )
                      : CommonMethods.showToast(message: 'not valid otp', type: ToastType.error);
                },
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
