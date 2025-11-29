import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/widget/hawiah_details.dart';
import 'package:hawiah_driver/features/order/presentation/widget/user_card_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class OldOrderScreen extends StatefulWidget {
  const OldOrderScreen({Key? key, required this.ordersDate}) : super(key: key);
  @override
  final SingleOrderData ordersDate;

  @override
  State<OldOrderScreen> createState() => _OldOrderScreenState();
}

class _OldOrderScreenState extends State<OldOrderScreen> {
  Widget build(BuildContext context) {
    final double totalPrice = double.tryParse(widget.ordersDate.totalPrice ?? "0") ?? 0;
    final double vat = totalPrice * 0.15;
    final double netTotal = totalPrice + vat;
    return Scaffold(
      appBar: CustomAppBar(
        context,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            AppLocaleKey.orderDetails.tr(),
            style: AppTextStyle.text16_700,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            widget.ordersDate.referenceNumber ?? "",
            style: AppTextStyle.text16_400,
          )
        ]),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HawiahDetails(ordersDate: widget.ordersDate),
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(8.0),
            //   ),
            //   child: Column(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Row(
            //           children: [
            //             Expanded(
            //               child: Row(
            //                 children: [
            //                   // Vehicle Image
            //                   CustomNetworkImage(
            //                     imageUrl: ordersDate.image ?? "",
            //                     fit: BoxFit.fill,
            //                     height: 60.h,
            //                     width: 60.w,
            //                   ),
            //                   SizedBox(width: 10),
            //                   Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(
            //                         ordersDate.product ?? "",
            //                         style: AppTextStyle.text16_700,
            //                       ),
            //                       SizedBox(height: 5.h),
            //                       RichText(
            //                         text: TextSpan(
            //                           children: [
            //                             TextSpan(
            //                               text: AppLocaleKey.orderNumber.tr(),
            //                               style: AppTextStyle.text16_600.copyWith(
            //                                 color: AppColor.blackColor.withValues(alpha: 0.7),
            //                               ),
            //                             ),
            //                             TextSpan(
            //                               text: ordersDate.referenceNumber ?? '',
            //                               style: AppTextStyle.text16_500.copyWith(
            //                                 color: AppColor.blackColor.withValues(alpha: 0.7),
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                       SizedBox(height: 5.h),
            //                       Text(
            //                         DateMethods.formatToFullData(
            //                           DateTime.tryParse(
            //                                 ordersDate.createdAt ?? "",
            //                               ) ??
            //                               DateTime.now(),
            //                         ),
            //                         style: AppTextStyle.text16_600.copyWith(
            //                           color: AppColor.blackColor.withValues(
            //                             alpha: 0.3,
            //                           ),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 16.0),

            SizedBox(height: 20.0),
            UserCardWidget(ordersData: widget.ordersDate),
            // Container(
            //   padding: const EdgeInsets.all(12.0),
            //   decoration: BoxDecoration(
            //     color: Colors.grey.shade50,
            //     borderRadius: BorderRadius.circular(12.0),
            //   ),
            //   child: Column(
            //     children: [
            //       Row(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Expanded(
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 SizedBox(height: 10.h),
            //                 Text(
            //                   AppLocaleKey.customerData.tr(),
            //                   style: AppTextStyle.text16_700,
            //                 ),
            //                 Text(
            //                   widget.ordersDate.user ?? "",
            //                   style: AppTextStyle.text16_700,
            //                 ),
            //                 SizedBox(height: 10.h),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 40.h),
            //       GestureDetector(
            //         onTap: () {
            //           NavigatorMethods.pushNamed(
            //             context,
            //             SingleChatScreen.routeName,
            //             arguments: SingleChatScreenArgs(
            //               receiverId: widget.ordersDate.userId.toString(),
            //               receiverType: "user",
            //               receiverName: widget.ordersDate.user ?? "",
            //               receiverImage: widget.ordersDate.userImage ?? "",
            //               senderId: context.read<ProfileCubit>().user.id.toString(),
            //               senderType: "driver",
            //               orderId: widget.ordersDate.id.toString(),
            //               onMessageSent: () {},
            //             ),
            //           );
            //         },
            //         child: Container(
            //           height: 50.h,
            //           padding: EdgeInsets.symmetric(
            //             horizontal: 10,
            //             vertical: 5,
            //           ),
            //           decoration: BoxDecoration(
            //             color: Color(0xffEEEEEE),
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           child: Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Text(
            //                 AppLocaleKey.sendMessage.tr(),
            //                 style: AppTextStyle.text14_500,
            //               ),
            //               SizedBox(width: 15),
            //               Image.asset(
            //                 AppImages.send,
            //                 height: 30.h,
            //                 width: 30.w,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 50.h),
            //       BlocBuilder<SettingCubit, SettingState>(
            //         builder: (context, state) {
            //           final setting = context.read<SettingCubit>().setting;
            //           return Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             children: [
            //               Column(
            //                 children: [
            //                   GestureDetector(
            //                     onTap: () {
            //                       _launchURL(
            //                         widget.ordersDate.userMobile ?? "",
            //                         isPhoneCall: true,
            //                       );
            //                     },
            //                     child: Container(
            //                       margin: EdgeInsets.symmetric(horizontal: 10),
            //                       padding: EdgeInsets.all(10),
            //                       decoration: BoxDecoration(
            //                         color: Color(0xffD9D9D9),
            //                         shape: BoxShape.circle,
            //                       ),
            //                       child: Image.asset(
            //                         AppImages.phone,
            //                         height: 30.h,
            //                         width: 30.w,
            //                       ),
            //                     ),
            //                   ),
            //                   SizedBox(height: 5),
            //                   Text(
            //                     AppLocaleKey.contactCustomer.tr(),
            //                     style: AppTextStyle.text16_500,
            //                   ),
            //                 ],
            //               ),
            //               Column(
            //                 children: [
            //                   GestureDetector(
            //                     onTap: () {
            //                       _launchURL(
            //                         setting?.phone ?? "",
            //                         isPhoneCall: true,
            //                       );
            //                     },
            //                     child: Container(
            //                       margin: EdgeInsets.symmetric(horizontal: 10),
            //                       padding: EdgeInsets.all(10),
            //                       decoration: BoxDecoration(
            //                         color: Color(0xffD9D9D9),
            //                         shape: BoxShape.circle,
            //                       ),
            //                       child: Image.asset(
            //                         AppImages.support,
            //                         height: 30.h,
            //                         width: 30.w,
            //                       ),
            //                     ),
            //                   ),
            //                   SizedBox(height: 5),
            //                   Text(
            //                     AppLocaleKey.support.tr(),
            //                     style: AppTextStyle.text16_500,
            //                   ),
            //                 ],
            //               ),
            //               Column(
            //                 children: [
            //                   GestureDetector(
            //                     onTap: () {
            //                       openMap(
            //                         widget.ordersDate.latitude.toString(),
            //                         widget.ordersDate.longitude.toString(),
            //                       );
            //                     },
            //                     child: Container(
            //                       margin: EdgeInsets.symmetric(horizontal: 10),
            //                       padding: EdgeInsets.all(10),
            //                       decoration: BoxDecoration(
            //                         color: Color(0xffD9D9D9),
            //                         shape: BoxShape.circle,
            //                       ),
            //                       child: Image.asset(
            //                         'assets/images/pin.png',
            //                         height: 30.h,
            //                         width: 30.w,
            //                       ),
            //                     ),
            //                   ),
            //                   SizedBox(height: 5),
            //                   Text(
            //                     AppLocaleKey.viewWebsite.tr(),
            //                     style: AppTextStyle.text16_500,
            //                   ),
            //                 ],
            //               ),
            //             ],
            //           );
            //         },
            //       ),
            //       SizedBox(height: 10.h),
            //     ],
            //   ),
            // ),
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

  void openMap(String lat, String lng) async {
    final Uri googleMapUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (!await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch map';
    }
  }
}
