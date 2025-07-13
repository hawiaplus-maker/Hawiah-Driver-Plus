import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/chat/presentation/screens/single-chat-screen.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/custom_widgets/global-elevated-button-widget.dart';
import 'order-otp-screen.dart';

class CurrentOrderScreen extends StatelessWidget {
  const CurrentOrderScreen({Key? key, required this.ordersDate})
    : super(key: key);
  final Data ordersDate;

  @override
  Widget build(BuildContext context) {
    final double totalPrice =
        double.tryParse(ordersDate.totalPrice ?? "0") ?? 0;
    final double vat = totalPrice * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب', style: AppTextStyle.text20_700),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
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
                                  Text(
                                    ordersDate.product ?? "",
                                    style: AppTextStyle.text16_700,
                                  ),
                                  SizedBox(height: 5.h),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: ' طلب رقم:',
                                          style: AppTextStyle.text16_600
                                              .copyWith(
                                                color: AppColor.blackColor
                                                    .withValues(alpha: 0.7),
                                              ),
                                        ),
                                        TextSpan(
                                          text:
                                              ordersDate.referenceNumber ?? '',
                                          style: AppTextStyle.text16_500
                                              .copyWith(
                                                color: AppColor.blackColor
                                                    .withValues(alpha: 0.7),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    DateMethods.formatToFullData(
                                      DateTime.tryParse(
                                            ordersDate.createdAt ?? "",
                                          ) ??
                                          DateTime.now(),
                                    ),
                                    style: AppTextStyle.text16_600.copyWith(
                                      color: AppColor.blackColor.withValues(
                                        alpha: 0.3,
                                      ),
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
            SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),

                            Text(
                              "بيانات العميل",
                              style: AppTextStyle.text16_700,
                            ),
                            Text(
                              ordersDate.user ?? "",
                              style: AppTextStyle.text16_700,
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  GestureDetector(
                    onTap: () {
                      NavigatorMethods.pushNamed(
                        context,
                        SingleChatScreen.routeName,
                        arguments: SingleChatScreenArgs(
                          reciverName: "محمد",
                          reciverImage: Urls.testUserImage,
                          senderId:
                              context.read<ProfileCubit>().user.id.toString(),
                          senderType: "user",
                          orderId: ordersDate.id.toString(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "إرسال رسالة ....",
                            style: AppTextStyle.text14_500,
                          ),
                          SizedBox(width: 15),
                          Image.asset(
                            AppImages.send,
                            height: 30.h,
                            width: 30.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 50.h),
                  BlocBuilder<SettingCubit, SettingState>(
                    builder: (context, state) {
                      final setting = context.read<SettingCubit>().setting;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => BlocBuilder<
                                      SettingCubit,
                                      SettingState
                                    >(
                                      builder: (context, state) {
                                        final setting =
                                            context
                                                .read<SettingCubit>()
                                                .setting;
                                        return AlertDialog(
                                          content: Container(
                                            height: 100.h,
                                            width: 200.h,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        _launchURL(
                                                          setting?.whatsApp ??
                                                              "",
                                                          isWhatsapp: true,
                                                        );
                                                      },
                                                      icon: Image.asset(
                                                        AppImages.whats,
                                                        height: 50.h,
                                                      ),
                                                    ),
                                                    Text('واتساب'),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    SizedBox(height: 5.h),
                                                    IconButton(
                                                      onPressed: () {
                                                        _launchURL(
                                                          setting?.phone ?? "",
                                                          isPhoneCall: true,
                                                        );
                                                      },
                                                      icon: Image.asset(
                                                        AppImages.phone,
                                                        height: 35.h,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.h),
                                                    Text('اتصال الهاتف'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xffD9D9D9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    AppImages.phone,
                                    height: 30.h,
                                    width: 30.w,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "تواصل مع العميل",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xffD9D9D9),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  AppImages.support,
                                  height: 30.h,
                                  width: 30.w,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "تواصل مع الدعم",
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _launchURL(
                                    setting?.email ?? "",
                                    isEmail: true,
                                  );
                                },
                                icon: Image.asset(
                                  AppImages.locationMapIcon,
                                  height: 45.h,
                                ),
                              ),
                              Text('عرض الموقع'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            SizedBox(height: 60.0),
            Container(
              child: Column(
                children: [
                  SizedBox(height: 50.0),
                  Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GlobalElevatedButton(
                      label: "تاكيد الطلب",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderOtpScreen(id: ordersDate.id),
                          ),
                        );
                      },
                      backgroundColor: Color(0xff1A3C98),
                      textColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      fixedWidth: 0.80, // 80% of the screen width
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
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
      uri = Uri.parse(
        "https://wa.me/${url.replaceAll('+', '').replaceAll(' ', '')}",
      );
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
}
