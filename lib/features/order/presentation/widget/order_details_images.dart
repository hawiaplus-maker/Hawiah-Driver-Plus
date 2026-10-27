import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';

/// Delivery-location images — same section style as the project pickup images.
class OrderDetailsImages extends StatelessWidget {
  const OrderDetailsImages({super.key, required this.images});

  final List<ContainerImage> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleKey.imagesFromDeliveryLocation.tr(),
          style: AppTextStyle.text16_700,
        ),
        Gap(16.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColor.mainAppColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return CustomNetworkImage(
                  radius: 5,
                  hasZoom: true,
                  imageUrl: image.url,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
