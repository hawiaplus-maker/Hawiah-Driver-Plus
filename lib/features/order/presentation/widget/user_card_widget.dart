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

/// Customer data card — same layout as the project pickup client card.
class UserCardWidget extends StatelessWidget {
  const UserCardWidget({
    super.key,
    required this.ordersData,
  });

  final SingleOrderModel ordersData;

  @override
  Widget build(BuildContext context) {
    if (ordersData.data?.orderStatus == 6) {
      return const SizedBox.shrink();
    }

    final mobile = _fullPhone(ordersData.data?.userMobile);

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
          Gap(10.h),
          Text(
            '${AppLocaleKey.name.tr()}: ${ordersData.data?.user ?? ''}',
            style: AppTextStyle.text16_400,
          ),
          Gap(20.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: AppLocaleKey.contactUser.tr(),
                  icon: AppImages.callImage,
                  background: AppColor.mainAppColor,
                  foreground: AppColor.whiteColor,
                  onTap: () => UrlLauncherMethods.makePhoneCall(mobile),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: _ActionButton(
                  label: AppLocaleKey.whatsab.tr(),
                  icon: AppImages.whatsappSupport,
                  background: AppColor.secondAppColor,
                  foreground: AppColor.mainAppColor,
                  borderColor: AppColor.mainAppColor,
                  onTap: () => UrlLauncherMethods.launchWhatsApp(mobile),
                ),
              ),
            ],
          ),
          Gap(10.h),
          _ActionButton(
            label: AppLocaleKey.chats.tr(),
            icon: AppImages.chatImage,
            background: AppColor.whiteColor,
            foreground: AppColor.mainAppColor,
            borderColor: AppColor.mainAppColor,
            onTap: () => _navigateToChat(context),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  String _fullPhone(String? mobile) {
    if (mobile == null || mobile.isEmpty) return '';
    return mobile.startsWith('+') ? mobile : '+966$mobile';
  }

  /// Navigation logic
  void _navigateToChat(BuildContext context) {
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.fullWidth = false,
  });

  final String label;
  final String icon;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: 45.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 14.h, width: 14.w),
            Gap(5.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.text14_500.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
