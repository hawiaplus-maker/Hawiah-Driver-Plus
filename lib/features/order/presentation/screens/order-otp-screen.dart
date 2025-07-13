import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/features/order/presentation/screens/confirmation_screen.dart';
import 'package:pinput/pinput.dart';

class OrderOtpScreen extends StatefulWidget {
  const OrderOtpScreen({Key? key, required this.id}) : super(key: key);

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
              SizedBox(height: 20),
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
                    "يرجى كتابة كود التحقيق المرفق مع العميل",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 30),
              SizedBox(height: 30),
              Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: otpController,
                    length: 5,
                    onChanged: (value) {
                      setState(() {
                        isOtpValid = value.length == 4;
                      });
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              SizedBox(height: 20),
              Spacer(),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GlobalElevatedButton(
                  label: "continue".tr(),
                  onPressed: () {
                    (isOtpValid)
                        ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ConfirmationScreen(
                                  otp: otpController.text,
                                  id: widget.id,
                                ),
                          ),
                        )
                        : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            elevation: 50,
                            backgroundColor: Colors.red,
                            content: Center(
                              child: Text(
                                'not valid otp',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        );
                  },
                  backgroundColor: Color(0xff1A3C98),
                  textColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: BorderRadius.circular(10),
                  fixedWidth: 0.80, // 80% of the screen width
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
