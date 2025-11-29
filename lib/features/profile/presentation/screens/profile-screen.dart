import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:hawiah_driver/features/profile/widget/profile_header_widget.dart';
import 'package:hawiah_driver/features/profile/widget/profile_menu_list.dart';
import 'package:hawiah_driver/injection_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onOrderTap});
  final VoidCallback onOrderTap;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        titleText: AppLocaleKey.profileFile.tr(),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = sl<ProfileCubit>();

          if (state is ProfileLoaded || cubit.user != null) {
            final user = cubit.user!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeaderWidget(user: user),
                  SizedBox(height: 20.h),
                  ProfileMenuList(onOrderTap: widget.onOrderTap),
                  SizedBox(height: 100.h),
                ],
              ),
            );
          }
          return const Center(child: Text("لا توجد بيانات"));
        },
      ),
    );
  }
}
