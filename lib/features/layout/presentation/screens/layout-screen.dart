import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/chat-screen.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
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
  @override
  void initState() {
    Future.wait([
      context.read<ProfileCubit>().fetchProfile(),
      context.read<SettingCubit>().getsetting(),
      context.read<OrderCubit>().getOrders(0),
    ]);

    super.initState();
  }

  int selectedIndex = 1;

  final List<Widget> _screens = [
    AllChatsScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Color(0xffE5E7FE),
        
        buttonBackgroundColor: const Color(0xff2B03F0),
        index: selectedIndex,
        items: [
          Image.asset(
            "assets/images/message.png",
            fit: BoxFit.fill,
            height: 25.h,
            width: 25.w,
            color:
                selectedIndex == 0
                    ? Colors.white
                    : Color(0xff929292), // Dynamically set the color
          ),
          Image.asset(
            "assets/icons/orders_icon.png",
            fit: BoxFit.fill,
            height: 25.h,
            width: 25.w,
            color:
                selectedIndex == 1
                    ? Colors.white
                    : Color(0xff929292), // Dynamically set the color
          ),
          Image.asset(
            "assets/icons/person_profile_icon.png",
            fit: BoxFit.fill,
            height: 25.h,
            width: 25.w,
            color:
                selectedIndex == 2
                    ? Colors.white
                    : Color(0xff929292), // Dynamically set the color
          ),
        ],
        backgroundColor: Colors.transparent,
        onTap:
            (int index) => setState(() {
              selectedIndex = index;
            }),
      ),
    );
  }
}
