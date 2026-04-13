import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/authentication/presentation/screens/login-screen.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth-cubit/auth-cubit.dart';
import '../controllers/auth-cubit/auth-state.dart';

class PersonalProfileCompletionScreen extends StatefulWidget {
  const PersonalProfileCompletionScreen({super.key, this.phoneNumber});
  final String? phoneNumber;
  @override
  State<PersonalProfileCompletionScreen> createState() =>
      _PersonalProfileCompletionScreenState();
}

class _PersonalProfileCompletionScreenState
    extends State<PersonalProfileCompletionScreen> {
  @override
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) {
          final authCubit = AuthCubit.get(context);

          bool passwordVisibleCompleteProfile =
              authCubit.passwordVisibleCompleteProfile;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Form(
                    key: authCubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            selectedImage != null
                                ? CircleAvatar(
                                    radius: 70.r,
                                    child: Image.file(
                                      selectedImage!,
                                      height: 0.22.sh,
                                      width: 0.45.sw,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 70.r,
                                    child: Image.asset(
                                      "assets/images/profileEmptyImage.png",
                                      height: 0.22.sh,
                                      width: 0.45.sw,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                            Positioned(
                              bottom: 5.h,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      selectedImage = File(image.path);
                                    });
                                  }
                                },
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Container(
                                      height: 50,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xff2204AE),
                                        border: Border.all(
                                            color: Colors.black, width: .5),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.h),
                        CustomTextField(
                          controller: authCubit.nameController,
                          labelText: "cream_name".tr(),
                          hintText: "cream_name".tr(),
                          onChanged: (value) {
                            authCubit.nameController.text = value;
                          },
                        ),

                        // DropdownButtonFormField<String>(
                        //   decoration: InputDecoration(labelText: "gender".tr()),
                        //   value: selectedGender ?? genders[0],
                        //   items: genders.map((gender) {
                        //     return DropdownMenuItem<String>(
                        //       value: gender,
                        //       child: Text(gender.tr()),
                        //     );
                        //   }).toList(),
                        //   onChanged: (value) {
                        //     authCubit.updateSelectedGender(value!);
                        //   },
                        //   // validator: (value) {
                        //   //   if (value == null) {
                        //   //     return 'Please select your gender';
                        //   //   }
                        //   //   return null;
                        //   // },
                        // ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          validator: authCubit.validatePassword,
                          controller:
                              authCubit.passwordControllerCompleteProfile,
                          labelText: 'password'.tr(),
                          hintText: 'enter_your_password'.tr(),
                          // obscureText: !passwordVisibleCompleteProfile,
                          // hasSuffixIcon: true,
                          isPassword: true,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          validator: (value) => authCubit.validateConfirmPassword(
                            value,
                            authCubit.passwordControllerCompleteProfile.text,
                          ),
                          controller: authCubit
                              .confirmPasswordControllerCompleteProfile,
                          labelText: 'confirm_password'.tr(),
                          hintText: 'enter_your_password'.tr(),
                          // obscureText: !passwordVisibleCompleteProfile,
                          // hasSuffixIcon: true,
                          isPassword: true,
                        ),
                        SizedBox(height: 0.30.sh),
                        GlobalElevatedButton(
                          label: "continue".tr(),
                          onPressed: () {
                            if (authCubit.formKey.currentState!.validate()) {
                              context.read<AuthCubit>().completeRegister(
                                    name: authCubit.nameController.text,
                                    phoneNumber: widget.phoneNumber,
                                    password: authCubit
                                        .passwordControllerCompleteProfile.text,
                                    password_confirmation: authCubit
                                        .confirmPasswordControllerCompleteProfile
                                        .text,
                                  );
                            }
                          },
                          backgroundColor: AppColor.selectedLightBlueColor,
                          textColor: AppColor.mainAppColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          borderRadius: BorderRadius.circular(12),
                          fixedWidth: 0.80, // 80% width of the screen
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state is AuthCompleteRegisterSuccess) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            AwesomeDialog(
              context: context,
              dialogType: DialogType.noHeader,
              animType: AnimType.rightSlide,
              customHeader: Image.asset(
                'assets/images/complete_register.png',
                height: 80,
                width: 80,
              ),
              title: "account_created_successfully".tr(),
              desc: "can_now_browse_services".tr(),
              btnOkOnPress: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              btnOkText: "continue_to_homepage".tr(),
              btnOkColor: Color(0xff2204AE), 
            )..show();
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
