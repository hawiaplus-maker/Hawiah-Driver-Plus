import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/url_luncher_methods.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';

/// Order data card — same layout as the project pickup details card, so the
/// regular orders, project pickups and cleaning contracts share one look.
class HawiahDetails extends StatelessWidget {
  const HawiahDetails({super.key, required this.ordersDate});

  final SingleOrderModel ordersDate;

  @override
  Widget build(BuildContext context) {
    final order = ordersDate.data;
    final statusEn = order?.status?.en ?? '';
    final status = context.locale.languageCode == 'ar'
        ? order?.status?.ar ?? ''
        : statusEn;
    final statusColor = gtOrderStatusColor(statusEn);
    final latitude = double.tryParse(order?.latitude ?? '');
    final longitude = double.tryParse(order?.longitude ?? '');
    final hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.mainAppColor, width: .3),
      ),
      child: Column(
        children: [
          // Header: title + status badge
          Row(
            children: [
              Text(AppLocaleKey.orderdata.tr(), style: AppTextStyle.text16_700),
              const Spacer(),
              if (status.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      status,
                      style: AppTextStyle.text16_500.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Gap(15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Vehicle image / container icon
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: (order?.image != null && order!.image!.isNotEmpty)
                    ? CustomNetworkImage(
                        imageUrl: order.image!,
                        fit: BoxFit.fill,
                        height: 60.h,
                        width: 60.w,
                      )
                    : Container(
                        height: 60.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: AppColor.mainAppColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppImages.containerIcon,
                            height: 32.h,
                            width: 32.w,
                            colorFilter: ColorFilter.mode(
                              AppColor.mainAppColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.product ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text16_700,
                    ),
                    Gap(5.h),
                    // Order code
                    Row(
                      children: [
                        Image.asset(
                          AppImages.codeImage,
                          height: 24.h,
                          width: 24.w,
                        ),
                        Gap(5.w),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${AppLocaleKey.orderCode.tr()} ',
                                  style: AppTextStyle.text14_600.copyWith(
                                    color: AppColor.blackColor,
                                  ),
                                ),
                                TextSpan(
                                  text: order?.referenceNumber ?? '',
                                  style: AppTextStyle.text14_500.copyWith(
                                    color: AppColor.greyColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Gap(5.h),
                    // Service provider
                    Row(
                      children: [
                        Image.asset(
                          AppImages.serviceProviderImage,
                          height: 24.h,
                          width: 24.w,
                        ),
                        Gap(5.w),
                        Flexible(
                          child: Text(
                            order?.serviceProvider ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.text14_500.copyWith(
                              color: AppColor.greyColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Location button (only when coordinates are available)
              if (hasLocation) ...[
                Gap(10.w),
                GestureDetector(
                  onTap: () => UrlLauncherMethods.launchGoogleMap(
                    latitude,
                    longitude,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.mainAppColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        AppImages.locationMainImage,
                        height: 20.h,
                        width: 20.w,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Gap(15.h),
          if (_hasValue(order?.address))
            _infoRow(AppLocaleKey.address.tr(), order!.address),
          if (_hasValue(order?.fromDate))
            _infoRow(AppLocaleKey.startdate.tr(), order!.fromDate),
          if (_hasValue(order?.toDate))
            _infoRow(AppLocaleKey.enddate.tr(), order!.toDate),
          if (_hasValue(order?.createdAt))
            _infoRow(AppLocaleKey.createdAt.tr(), order!.createdAt),
        ],
      ),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.text16_400),
          Gap(8.w),
          Expanded(
            child: Text(
              value ?? '---',
              textAlign: TextAlign.start,
              style: AppTextStyle.text16_400.copyWith(
                color: AppColor.greyColor.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
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
