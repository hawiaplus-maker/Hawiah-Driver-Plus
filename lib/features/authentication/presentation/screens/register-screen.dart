import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/verification-otp-screen.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/common/appbar-auth-sidget.dart';
import 'package:hawiah_driver/features/authentication/presentation/widgets/common/phone-input-widget.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';

import '../controllers/auth-cubit/auth-cubit.dart';
import '../controllers/auth-cubit/auth-state.dart';
import '../widgets/register-widgets/account-type-toggle-widget.dart';
import '../widgets/register-widgets/footer-register-widget.dart';
import '../widgets/register-widgets/register-button-widget.dart';
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
      resizeToAvoidBottomInset: false,
      appBar: CustomAuthAppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(builder: (BuildContext context, AuthState state) {
        final authChange = AuthCubit.get(context);
        final accountTypes = authChange.accountTypes;
        final selectedAccountType = authChange.selectedAccountType;
        final checkedValueTerms = authChange.checkedValueTerms;
        final selectedTypeValue = selectedAccountType == 0 ? 'individual' : 'company';
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WelcomeTextWidget(),
                SizedBox(height: 30.h),
                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  final authChange = context.watch<AuthCubit>();
                  return AccountTypeToggleWidget(
                    selectedAccountType: authChange.selectedAccountType,
                    accountTypes: authChange.accountTypes,
                    onToggle: (index) {
                      setState(() {
                        authChange.updateSelectedAccountType(index!);
                      });
                    },
                  );
                }),
                SizedBox(height: 60.h),
                PhoneInputWidget(
                  controller: authChange.phoneControllerRegister,
                ),
                SizedBox(height: 40.h),
                RegisterButtonWidget(
                  formKey: formKey,
                  type: selectedTypeValue,
                ),
                SizedBox(height: 40.h),
                BlocProvider(
                  create: (context) => SettingCubit(),
                  child: TermsAndConditionsSection(
                    checkedValueTerms: checkedValueTerms,
                    onCheckboxChanged: (value) {
                      authChange.updateCheckedValueTerms(value ?? false);
                    },
                  ),
                ),
                Spacer(),
                FooterRegisterWidget(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }, listener: (context, state) {
        if (state is AuthSuccess) {
          Fluttertoast.showToast(
            msg: state.message,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VerificationOtpScreen(
                      phoneNumber: state.data?['mobile'],
                      otp: state.data?['otp'],
                    )),
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
      }),
    );
  }
}
