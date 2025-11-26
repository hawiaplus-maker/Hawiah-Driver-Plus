import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/screens/order-otp-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_state.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentOrderScreen extends StatelessWidget {
  const CurrentOrderScreen(
      {Key? key, required this.ordersDate, required SingleOrderData ordersData})
      : super(key: key);
  final SingleOrderData ordersDate;

  @override
  Widget build(BuildContext context) {
    final double totalPrice = double.tryParse(ordersDate.totalPrice ?? "0") ?? 0;
    final double vat = totalPrice * 0.15;
    final isDelivered = ordersDate.status != null &&
        ordersDate.status is Map &&
        (ordersDate.status!['en'] == "Delivered");
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocaleKey.orderDetails.tr(), style: AppTextStyle.text20_700),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Vehicle Image
                              CustomNetworkImage(
                                imageUrl: ordersDate.image ?? "",
                                fit: BoxFit.fill,
                                height: 60.h,
                                width: 60.w,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ordersDate.product ?? "", style: AppTextStyle.text16_700),
                                  SizedBox(height: 5.h),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: AppLocaleKey.orderNumber.tr(),
                                          style: AppTextStyle.text16_600.copyWith(
                                            color: AppColor.blackColor.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ordersDate.referenceNumber ?? '',
                                          style: AppTextStyle.text16_500.copyWith(
                                            color: AppColor.blackColor.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    DateMethods.formatToFullData(
                                      DateTime.tryParse(ordersDate.createdAt ?? "") ??
                                          DateTime.now(),
                                    ),
                                    style: AppTextStyle.text16_600.copyWith(
                                      color: AppColor.blackColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Text(AppLocaleKey.customerData.tr(), style: AppTextStyle.text16_700),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocaleKey.name.tr()} ${ordersDate.user ?? ""}',
                        style: AppTextStyle.text16_700,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      NavigatorMethods.pushNamed(
                        context,
                        SingleChatScreen.routeName,
                        arguments: SingleChatScreenArgs(
                          receiverId: ordersDate.userId.toString(),
                          receiverType: "user",
                          receiverName: ordersDate.user ?? "",
                          receiverImage: ordersDate.userImage ?? "",
                          senderId: context.read<ProfileCubit>().user.id.toString(),
                          senderType: "driver",
                          orderId: ordersDate.id.toString(),
                          onMessageSent: () {},
                        ),
                      );
                    },
                    child: Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocaleKey.sendMessage.tr(), style: AppTextStyle.text14_500),
                          SizedBox(width: 15),
                          Image.asset(AppImages.send, height: 30.h, width: 30.w),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  BlocBuilder<SettingCubit, SettingState>(
                    builder: (context, state) {
                      final setting = context.read<SettingCubit>().setting;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _launchURL(ordersDate.userMobile ?? "", isPhoneCall: true);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xffD9D9D9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(AppImages.phone, height: 30.h, width: 30.w),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                AppLocaleKey.contactCustomer.tr(),
                                style: AppTextStyle.text16_500,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _launchURL(setting?.phone ?? "", isPhoneCall: true);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xffD9D9D9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(AppImages.support, height: 30.h, width: 30.w),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(AppLocaleKey.support.tr(), style: AppTextStyle.text16_500),
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  openMap(
                                    ordersDate.latitude.toString(),
                                    ordersDate.longitude.toString(),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xffD9D9D9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/pin.png',
                                    height: 30.h,
                                    width: 30.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(AppLocaleKey.viewWebsite.tr(), style: AppTextStyle.text16_500),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  //  CustomButton(text: AppLocaleKey.confirm.tr()),
                  SizedBox(height: 250.h),
                  isDelivered
                      ? SizedBox()
                      : Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                          child: GlobalElevatedButton(
                            label: AppLocaleKey.confirmOrder.tr(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderOtpScreen(
                                    otp: ordersDate.otp ?? "",
                                    id: ordersDate.id,
                                  ),
                                ),
                              );
                            },
                            backgroundColor: Color(0xff1A3C98),
                            textColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            borderRadius: BorderRadius.circular(10),
                            fixedWidth: 0.80,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(
    String? url, {
    bool isWhatsapp = false,
    bool isEmail = false,
    bool isPhoneCall = false,
  }) async {
    if (url == null || url.isEmpty) return;

    Uri uri;

    if (isWhatsapp) {
      uri = Uri.parse("https://wa.me/${url.replaceAll('+', '').replaceAll(' ', '')}");
    } else if (isEmail) {
      uri = Uri.parse("mailto:$url");
    } else if (isPhoneCall) {
      uri = Uri.parse("tel:$url");
    } else {
      uri = Uri.parse(url);
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  void openMap(String lat, String lng) async {
    final Uri googleMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (!await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch map';
    }
  }
}
