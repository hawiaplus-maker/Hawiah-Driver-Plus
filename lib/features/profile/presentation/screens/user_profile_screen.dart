import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom-text-field-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:hawiah_driver/features/profile/widget/custom_dialog_widget.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  static const String routeName = '/userprofile';
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _controllers = {
    "name": TextEditingController(),
    "mobile": TextEditingController(),
  };

  final _picker = ImagePicker();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));
    Fluttertoast.showToast(msg: AppLocaleKey.imageSelected.tr());
  }

  @override
  void initState() {
    final cubit = sl<ProfileCubit>();
    if (cubit.user != null) {
      _controllers['name']!.text = cubit.user!.name;
      _controllers['mobile']!.text = cubit.user!.mobile;
    }
    super.initState();
  }

  void _onUpdatePressed() async {
    log('============================= Update Pressed ==============================');
    final cubit = sl<ProfileCubit>();

    // تعديل: جلب الإيميل الحالي للمستخدم لتجنب إرسال قيمة فارغة
    String currentEmail = cubit.user?.email ?? '';

    await cubit.updateProfile(
      name: _controllers['name']!.text,
      mobile: _controllers['mobile']!.text,
      email: currentEmail, // تم التعديل هنا
      imageFile: _pickedImage,
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    final imageProvider = _pickedImage != null
        ? FileImage(_pickedImage!)
        : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : AssetImage(AppImages.profileEmptyImage))
            as ImageProvider;

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(radius: 60, backgroundImage: imageProvider),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColor.mainAppColor,
            child: Icon(Icons.camera_alt_outlined, color: AppColor.whiteColor, size: 18),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTextFields() => _controllers.entries
      .map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CustomTextField(
              title: entry.key.tr(),
              controller: entry.value,
            ),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context, titleText: AppLocaleKey.profileFile.tr(), centerTitle: true),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: sl<ProfileCubit>(),
        listener: (context, state) async {
          if (state is ProfileUpdateSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => CustomConfirmDialog(
                content: AppLocaleKey.saveChangesSuccess
                    .tr(), // تم تعديل النص ليأخذ قيمة ديناميكية من الstate لو أردت state.message
                image: AppImages.successGif,
              ),
            );

            await Future.delayed(const Duration(seconds: 3)); // تقليل المدة قليلاً
            if (mounted) Navigator.pop(context);
          }

          if (state is ProfileError) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => CustomConfirmDialog(
                content: AppLocaleKey.somethingWentWrong.tr(),
                image: AppImages.errorSvg,
              ),
            );

            await Future.delayed(const Duration(seconds: 3));
            if (mounted) Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final cubit = sl<ProfileCubit>();
          final user = cubit.user;

          if (user == null) {
            return const Center(child: CustomLoading());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                // إضافة Scroll لتجنب Overflow
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildProfileImage(user.image),
                    const SizedBox(height: 30),
                    ..._buildTextFields(),
                    Gap(40.h),
                    // التحقق من حالتين: التحميل العام أو التحديث
                    (state is ProfileLoading || state is ProfileUpdating)
                        ? const CustomLoading()
                        : CustomButton(
                            onPressed: _onUpdatePressed,
                            child: Text(
                              AppLocaleKey.saveChanges.tr(),
                              style: AppTextStyle.text16_600.copyWith(color: AppColor.whiteColor),
                            ),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
