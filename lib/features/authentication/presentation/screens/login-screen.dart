import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-cubit.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-state.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/forget-password-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/common/appbar-auth-sidget.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/common/phone-input-widget.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/login-widgets/action-buttons-widget.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/login-widgets/password-input-widget.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login-screen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAuthAppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          return Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("welcome".tr(), style: AppTextStyle.text20_700),
                  Text(
                    "welcome_back".tr(),
                    style: TextStyle(fontSize: 15.sp, color: Color(0xff979797)),
                  ),
                  SizedBox(height: 20.h),
                  PhoneInputWidget(
                    controller: AuthCubit.get(context).PhoneController,
                  ),
                  SizedBox(height: 20.h),
                  PasswordInputWidget(),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "forgot_password".tr(),
                        style: TextStyle(
                          color: AppColor.mainAppColor,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ActionButtonsWidget(formKey: formKey),
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
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            HiveMethods.updateIsVisitor(false);
            Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const LayoutScreen(),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
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
