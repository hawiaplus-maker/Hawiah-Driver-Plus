import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_shimmer.dart';
import 'package:hawiah_driver/core/images/app_images.dart' show AppImages;
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/notifications/presentation/screen/notifications_screen.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = sl<ProfileCubit>();
      // The splash screen now gates entry with user-info
      // (service-providers/user-info), so users/profile may not have been
      // fetched yet — load it here on first open.
      if (cubit.user == null) {
        cubit.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        titleText: AppLocaleKey.profileFile.tr(),
        actions: [
          IconButton(
            icon: SvgPicture.asset(AppImages.notificationDot),
            onPressed: () {
              NavigatorMethods.pushNamed(context, NotificationsScreen.routeName);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        bloc: sl<ProfileCubit>(),
        builder: (context, state) {
          final user = sl<ProfileCubit>().user;
          if (user == null) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  CustomShimmer(
                    height: 180.h,
                    width: double.infinity,
                    radius: 15,
                  ),
                  SizedBox(height: 20.h),
                  CustomShimmer(height: 400.h, width: double.infinity, radius: 15),
                ],
              ),
            );
          }
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
        },
      ),
    );
  }
}
