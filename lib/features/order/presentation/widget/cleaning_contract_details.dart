import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/url_luncher_methods.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';

/// Contract details card — styled like [HawiahDetails] (order data card).
class CleaningContractDetails extends StatelessWidget {
  const CleaningContractDetails({super.key, required this.order});

  final CleaningContractDeliveryItem order;

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.deliveryStatus?.toLowerCase() == 'delivered';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.mainAppColor, width: .3),
      ),
      child: Column(
        children: [
          // Header: title + delivery status badge
          Row(
            children: [
              Text(AppLocaleKey.orderdata.tr(), style: AppTextStyle.text16_700),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: statusColor(isDelivered).withAlpha(50),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      order.deliveryStatusDisplay,
                      style: AppTextStyle.text16_500.copyWith(
                        color: statusColor(isDelivered),
                      ),
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
              // Container image / icon
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: order.deliveryImage != null && order.deliveryImage!.isNotEmpty
                    ? CustomNetworkImage(
                        imageUrl: order.deliveryImage!,
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
                      order.containerName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text16_700,
                    ),
                    Gap(5.h),
                    // Contract code
                    Row(
                      children: [
                        Image.asset(AppImages.codeImage, height: 24.h, width: 24.w),
                        Gap(5.w),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${AppLocaleKey.contractNumber.tr()}: ',
                                  style: AppTextStyle.text14_600.copyWith(
                                    color: AppColor.blackColor,
                                  ),
                                ),
                                TextSpan(
                                  text: order.contractNumber ?? '',
                                  style: AppTextStyle.text14_500.copyWith(
                                    color: AppColor.greyColor.withValues(alpha: 0.7),
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
                    // Company
                    Row(
                      children: [
                        Image.asset(AppImages.serviceProviderImage, height: 24.h, width: 24.w),
                        Gap(5.w),
                        Flexible(
                          child: Text(
                            order.companyName ?? '',
                            style: AppTextStyle.text14_500.copyWith(
                              color: AppColor.greyColor.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Gap(5.h),
                    // City
                    Row(
                      children: [
                        Image.asset(AppImages.locationMainImage, height: 24.h, width: 24.w),
                        Gap(5.w),
                        Flexible(
                          child: Text(
                            order.cityName ?? '',
                            style: AppTextStyle.text14_500.copyWith(
                              color: AppColor.greyColor.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Location button (only when coordinates available)
              if (_hasLocation) ...[
                Gap(10.w),
                GestureDetector(
                  onTap: () => UrlLauncherMethods.launchGoogleMap(
                    double.tryParse(order.deliveryLatitude?.toString() ??
                        order.latitude?.toString() ??
                        "0.0") ??
                        0.0,
                    double.tryParse(order.deliveryLongitude?.toString() ??
                        order.longitude?.toString() ??
                        "0.0") ??
                        0.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.mainAppColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
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
            ],
          ),
          Gap(15.h),
          _infoRow(AppLocaleKey.address.tr(), order.address),
          _infoRow(AppLocaleKey.container.tr(),
              '${order.containerSize ?? ''} × ${order.containerQuantity ?? ''}'),
          if (order.startDate != null)
            _infoRow(AppLocaleKey.startdate.tr(), order.startDate),
          if (order.endDate != null) _infoRow(AppLocaleKey.enddate.tr(), order.endDate),
          if (isDelivered && order.deliveredAt != null)
            _infoRow(AppLocaleKey.createdAt.tr(), order.deliveredAt),
        ],
      ),
    );
  }

  bool get _hasLocation {
    final lat = double.tryParse(order.deliveryLatitude?.toString() ??
        order.latitude?.toString() ??
        '');
    final lng = double.tryParse(order.deliveryLongitude?.toString() ??
        order.longitude?.toString() ??
        '');
    return lat != null && lng != null;
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

  Color statusColor(bool isDelivered) {
    return isDelivered ? AppColor.mainAppColor : AppColor.textGrayColor;
  }
}

/// Company data card — styled like [UserCardWidget] (customer data card).
class CleaningContractCompanyCard extends StatelessWidget {
  const CleaningContractCompanyCard({super.key, required this.order});

  final CleaningContractDeliveryItem order;

  @override
  Widget build(BuildContext context) {
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
          Text('${AppLocaleKey.company.tr()}: ${order.companyName ?? ''}',
              style: AppTextStyle.text16_400),
          Gap(20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => UrlLauncherMethods.makePhoneCall(
                      "+966${order.companyPhone ?? ""}"),
                  child: Container(
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: AppColor.mainAppColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.callImage,
                            height: 14.h, width: 14.w, fit: BoxFit.cover),
                        Gap(5.w),
                        Text(AppLocaleKey.contactUser.tr(),
                            style: AppTextStyle.text14_500
                                .copyWith(color: AppColor.whiteColor)),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => UrlLauncherMethods.launchWhatsApp(
                      "+966${order.companyPhone ?? ""}"),
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
            ],
          ),
        ],
      ),
    );
  }
}

/// Delivery image section — styled like the typical order details images grid.
class CleaningContractDeliveryImages extends StatelessWidget {
  const CleaningContractDeliveryImages({super.key, required this.order});

  final CleaningContractDeliveryItem order;

  @override
  Widget build(BuildContext context) {
    if (order.deliveryImage == null || order.deliveryImage!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocaleKey.imagesFromDeliveryLocation.tr(), style: AppTextStyle.text16_700),
        Gap(16.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColor.mainAppColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomNetworkImage(
              radius: 5,
              hasZoom: true,
              imageUrl: order.deliveryImage!,
            ),
          ),
        ),
      ],
    );
  }
}
