import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/chat-screen.dart';
import 'package:hawiah_driver/features/order/presentation/screens/orders-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/profile-screen.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';

class LayoutScreen extends StatefulWidget {
  static const routeName = '/layout-screen';
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int selectedIndex = 1;

  @override
  void initState() {
    context.read<ProfileCubit>().fetchProfile();
    context.read<SettingCubit>().getsetting();
    super.initState();
  }

  void onProfileOrderTap() {
    setState(() => selectedIndex = 1);
  }

  List<Widget> get _screens => [
        const AllChatsScreen(),
        const OrdersScreen(),
        ProfileScreen(onOrderTap: onProfileOrderTap),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.mainAppColor,
        unselectedItemColor: AppColor.greyColor,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppImages.message,
                height: 24.h,
                width: 24.w,
                color: selectedIndex == 0 ? AppColor.mainAppColor : AppColor.greyColor),
            label: AppLocaleKey.messages.tr(),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppImages.logs,
                height: 24.h,
                width: 24.w,
                color: selectedIndex == 1 ? AppColor.mainAppColor : AppColor.greyColor),
            label: AppLocaleKey.ordersPage.tr(),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppImages.userSvg,
                height: 24.h,
                width: 24.w,
                color: selectedIndex == 2 ? AppColor.mainAppColor : AppColor.greyColor),
            label: AppLocaleKey.profileFile.tr(),
          ),
        ],
      ),
    );
  }
}
