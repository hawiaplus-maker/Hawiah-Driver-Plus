import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/url_luncher_methods.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';

class HawiahDetails extends StatelessWidget {
  const HawiahDetails({super.key, required this.ordersDate});
  final SingleOrderModel ordersDate;
  @override
  Widget build(BuildContext context) {
    final status = context.locale.languageCode == 'ar'
        ? ordersDate.data?.status?.ar ?? ''
        : ordersDate.data?.status?.en ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(10.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColor.mainAppColor, width: .3),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(AppLocaleKey.orderdata.tr(), style: AppTextStyle.text16_700),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: gtOrderStatusColor(ordersDate.data?.status?.en ?? '').withAlpha(50),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          status,
                          style: AppTextStyle.text16_500.copyWith(
                            color: gtOrderStatusColor(ordersDate.data?.status?.en ?? ''),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vehicle Image
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CustomNetworkImage(
                        imageUrl: ordersDate.data?.image ?? "",
                        fit: BoxFit.fill,
                        height: 60.h,
                        width: 60.w,
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ordersDate.data?.product ?? "",
                        style: AppTextStyle.text16_700,
                      ),
                      Gap(15.h),
                      Row(
                        children: [
                          Image.asset(AppImages.codeImage, height: 24.h, width: 24.w),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocaleKey.orderCode.tr(),
                                  style: AppTextStyle.text14_600.copyWith(
                                    color: AppColor.blackColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ordersDate.data?.referenceNumber ?? '',
                                  style: AppTextStyle.text14_500.copyWith(
                                    color: AppColor.greyColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap(15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(AppImages.serviceProviderImage, height: 24.h, width: 24.w),
                          Text(
                            ordersDate.data?.serviceProvider.toString() ?? '',
                            style: AppTextStyle.text14_500.copyWith(
                              color: AppColor.greyColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      UrlLauncherMethods.launchGoogleMap(
                          double.tryParse(ordersDate.data?.latitude ?? "0.0") ?? 0.0,
                          double.tryParse(ordersDate.data?.longitude ?? "0.0") ?? 0.0);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.mainAppColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocaleKey.location.tr(),
                              style: AppTextStyle.text14_500,
                            ),
                            Image.asset(
                              AppImages.locationMainImage,
                              height: 20.h,
                              width: 20.w,
                            ),
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
      ],
    );
  }

  Color gtOrderStatusColor(String status) {
    switch (status) {
      case "Delivered":
        return AppColor.mainAppColor;
      case "Processing":
        return AppColor.statusOrangeColor;
      case "New order":
        return AppColor.statusBlueColor;
      case "Out for delivery":
        return AppColor.redColor;
      case "Finish Order":
        return AppColor.mainAppColor;
      default:
        return AppColor.textGrayColor;
    }
  }
}
