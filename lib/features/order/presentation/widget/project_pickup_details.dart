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
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';

/// Project pickup details card — styled like [HawiahDetails] (order data card).
class ProjectPickupDetails extends StatelessWidget {
  const ProjectPickupDetails({super.key, required this.pickup});

  final ProjectDischargeItem pickup;

  @override
  Widget build(BuildContext context) {
    final isCompleted = pickup.isCompleted;

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
              Container(
                decoration: BoxDecoration(
                  color: _statusColor(isCompleted).withAlpha(50),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      pickup.statusDisplay,
                      style: AppTextStyle.text16_500.copyWith(
                        color: _statusColor(isCompleted),
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
              // Container icon / before image
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: (pickup.imageBefore != null && pickup.imageBefore!.isNotEmpty)
                    ? CustomNetworkImage(
                        imageUrl: pickup.imageBefore!,
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
                      pickup.projectName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text16_700,
                    ),
                    Gap(5.h),
                    // Reference number
                    Row(
                      children: [
                        Image.asset(AppImages.codeImage, height: 24.h, width: 24.w),
                        Gap(5.w),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${AppLocaleKey.referenceNumber.tr()}: ',
                                  style: AppTextStyle.text14_600.copyWith(
                                    color: AppColor.blackColor,
                                  ),
                                ),
                                TextSpan(
                                  text: pickup.referenceNumber ?? '',
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
                    // Client
                    Row(
                      children: [
                        Image.asset(AppImages.serviceProviderImage, height: 24.h, width: 24.w),
                        Gap(5.w),
                        Flexible(
                          child: Text(
                            pickup.clientName ?? '',
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
              if (pickup.locationLatitude != null && pickup.locationLongitude != null) ...[
                Gap(10.w),
                GestureDetector(
                  onTap: () => UrlLauncherMethods.launchGoogleMap(
                    pickup.locationLatitude!,
                    pickup.locationLongitude!,
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
          _infoRow(AppLocaleKey.container.tr(),
              '${pickup.containerName ?? ''}${pickup.containerSize != null ? ' (${pickup.containerSize} ياردة)' : ''}'),
          if (pickup.dischargesCount != null)
            _infoRow(AppLocaleKey.discharges.tr(),
                pickup.dischargesCount?.toString() ?? '0'),
          _infoRow(AppLocaleKey.completedPickupsLabel.tr(),
              '${pickup.completedPickups ?? 0} / ${pickup.totalPickups ?? 0}'),
          if (pickup.scheduledDate != null)
            _infoRow(AppLocaleKey.scheduledDate.tr(),
                '${pickup.scheduledDate ?? ''}${pickup.scheduledTime != null ? ' - ${_formatTime(pickup.scheduledTime!)}' : ''}'),
          if (pickup.clientNotes != null && pickup.clientNotes!.isNotEmpty)
            _infoRow(AppLocaleKey.clientNotes.tr(), pickup.clientNotes),
          if (isCompleted && pickup.completedAt != null)
            _infoRow(AppLocaleKey.createdAt.tr(), pickup.completedAt),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12:$minute $period';
    }
    return time;
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

  Color _statusColor(bool isCompleted) {
    return isCompleted ? AppColor.mainAppColor : AppColor.textGrayColor;
  }
}

/// Client data card — styled like [UserCardWidget] (customer data card).
class ProjectPickupClientCard extends StatelessWidget {
  const ProjectPickupClientCard({super.key, required this.pickup});

  final ProjectDischargeItem pickup;

  @override
  Widget build(BuildContext context) {
    String fullPhone(String? mobile) {
      if (mobile == null || mobile.isEmpty) return '';
      return mobile.startsWith('+') ? mobile : '+966$mobile';
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
          Gap(10.h),
          Text('${AppLocaleKey.clientName.tr()}: ${pickup.clientName ?? ''}',
              style: AppTextStyle.text16_400),
          Gap(20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => UrlLauncherMethods.makePhoneCall(fullPhone(pickup.clientMobile)),
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
                  onTap: () => UrlLauncherMethods.launchWhatsApp(fullPhone(pickup.clientMobile)),
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

/// Pickup images section — every shot is separated and titled on its own:
/// the container picture taken before the trip, the one taken after the
/// discharge and the delivery proof.
class ProjectPickupImages extends StatelessWidget {
  const ProjectPickupImages({super.key, required this.pickup});

  final ProjectDischargeItem pickup;

  @override
  Widget build(BuildContext context) {
    final before = _validUrl(pickup.imageBefore);
    final after = _validUrl(pickup.imageAfter);
    final proof = _validUrl(pickup.proofImage);

    if (before == null && after == null && proof == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (before != null) ...[
          Text(AppLocaleKey.hawiahImageBefore.tr(),
              style: AppTextStyle.text16_700),
          Gap(16.h),
          _PickupImage(url: before),
        ],
        if (after != null) ...[
          Gap(20.h),
          Text(AppLocaleKey.hawiahImageAfter.tr(),
              style: AppTextStyle.text16_700),
          Gap(16.h),
          _PickupImage(url: after),
        ],
        if (proof != null) ...[
          Gap(20.h),
          Text(AppLocaleKey.hawiahProofImage.tr(),
              style: AppTextStyle.text16_700),
          Gap(16.h),
          _PickupImage(url: proof),
        ],
      ],
    );
  }

  /// Returns the url when it carries a real value, `null` otherwise.
  String? _validUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    return url;
  }
}

/// A single pickup shot — bordered and zoomable.
class _PickupImage extends StatelessWidget {
  const _PickupImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColor.mainAppColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CustomNetworkImage(
          imageUrl: url,
          width: double.infinity,
          height: 200.h,
          radius: 5,
          hasZoom: true,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
