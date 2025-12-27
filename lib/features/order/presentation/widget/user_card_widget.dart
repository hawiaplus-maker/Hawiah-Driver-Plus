import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/core/utils/url_luncher_methods.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/injection_container.dart';

class UserCardWidget extends StatelessWidget {
  const UserCardWidget({
    super.key,
    required this.ordersData,
  });

  final SingleOrderModel ordersData;

  @override
  Widget build(BuildContext context) {
    final user = sl<ProfileCubit>().user;

    final driverName = user?.name ?? "";
    if (ordersData.data?.orderStatus == 6) {
      return SizedBox();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.mainAppColor, width: .3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocaleKey.customerData.tr(), style: AppTextStyle.text16_700),
          _buildDriverInfo(driverName, context),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(String driverName, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppLocaleKey.name.tr()}: ${ordersData.data?.user}',
                    style: AppTextStyle.text16_400),
                Gap(20.h),
                GestureDetector(
                  onTap: () =>
                      UrlLauncherMethods.makePhoneCall("+966${ordersData.data?.userMobile ?? ""}"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.mainAppColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.phoneSupport,
                            height: 14.h, width: 14.w, fit: BoxFit.cover),
                        Gap(5.w),
                        Text(AppLocaleKey.contactUser.tr(),
                            style: AppTextStyle.text14_500.copyWith(color: AppColor.whiteColor)),
                      ],
                    ),
                  ),
                ),
                Gap(10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => UrlLauncherMethods.launchWhatsApp(
                            "+966${ordersData.data?.userMobile ?? ""}"),
                        child: Container(
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: AppColor.secondAppColor,
                            border: Border.all(color: AppColor.mainAppColor, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.whatsappSupport, height: 14.h, width: 14.w),
                              Gap(5.w),
                              Text(AppLocaleKey.whatsab.tr(),
                                  style: AppTextStyle.text16_600
                                      .copyWith(color: AppColor.mainAppColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToChat(context, driverName),
                        child: Container(
                          height: 45.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.mainAppColor, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.chats, height: 14.h, width: 14.w),
                              Gap(5.w),
                              Text(AppLocaleKey.chats.tr(),
                                  style: AppTextStyle.text16_600
                                      .copyWith(color: AppColor.mainAppColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///  Navigation logic
  void _navigateToChat(BuildContext context, String driverName) {
    final driver = sl<ProfileCubit>().user;

    NavigatorMethods.pushNamed(
      context,
      SingleChatScreen.routeName,
      arguments: SingleChatScreenArgs(
        receiverId: ordersData.data?.userId.toString() ?? "",
        receiverType: "user",
        receiverName: ordersData.data?.user ?? "",
        receiverImage: ordersData.data?.image ?? "",
        senderId: driver?.id.toString() ?? "",
        senderType: "driver",
        orderId: ordersData.data?.id.toString() ?? "",
        onMessageSent: () {},
      ),
    );
  }
}
