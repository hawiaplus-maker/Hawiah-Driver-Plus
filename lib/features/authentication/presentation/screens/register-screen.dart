import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/common/appbar-auth-sidget.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/common/phone-input-widget.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';

import '../controllers/auth-cubit/auth-cubit.dart';
import '../controllers/auth-cubit/auth-state.dart';
import '../widgets/register-widgets/footer-register-widget.dart';
import '../widgets/register-widgets/name-input-widget.dart';
import '../widgets/register-widgets/register-button-widget.dart';
import '../widgets/register-widgets/register-password-input-widget.dart';
import '../widgets/register-widgets/terms-and-conditions-section.dart';
import '../widgets/register-widgets/welcome-text-widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAuthAppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          final authCubit = AuthCubit.get(context);

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WelcomeTextWidget(),
                    SizedBox(height: 32.h),
                    NameInputWidget(),
                    SizedBox(height: 16.h),
                    PhoneInputWidget(
                      controller: authCubit.phoneControllerRegister,
                    ),
                    SizedBox(height: 16.h),
                    RegisterPasswordInputWidget(),
                    SizedBox(height: 16.h),
                    TermsAndConditionsSection(
                      checkedValueTerms: authCubit.checkedValueTerms,
                      onCheckboxChanged: (value) {
                        authCubit.updateCheckedValueTerms(value ?? false);
                      },
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: RegisterButtonWidget(formKey: formKey),
                    ),
                    SizedBox(height: 24.h),
                    FooterRegisterWidget(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state is AuthRegisterSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => state.isAuthenticated
                    ? const LayoutScreen()
                    : const LoginScreen(),
              ),
              (route) => false,
            );
          }
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
        },
      ),
    );
  }
}
