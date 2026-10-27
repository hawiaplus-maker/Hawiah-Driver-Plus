import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/screens/current-order-screen.dart';
import 'package:hawiah_driver/features/order/presentation/screens/old-order-screen.dart';

class CleaningContractOrderCardWidget extends StatelessWidget {
  const CleaningContractOrderCardWidget({super.key, required this.order});

  final CleaningContractDeliveryItem order;

  static const _doneStates = {'delivered', 'discharged', 'completed'};

  bool get _isDone => _doneStates.contains(order.deliveryStatus?.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final isDelivered = _isDone;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColor.mainAppColor.withAlpha(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("#${order.contractNumber ?? '---'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.text16_500),
                      Text(order.containerName ?? '---',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.text14_400),
                      const SizedBox(height: 5),
                      Text(
                        '${AppLocaleKey.company.tr()} ${order.companyName ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.text14_400.copyWith(
                          color: AppColor.textGrayColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.remove_red_eye_outlined,
                              color: AppColor.lightGreyColor, size: 15),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              AppLocaleKey.showDetails.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.text16_600.copyWith(
                                color: AppColor.mainAppColor,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.mainAppColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _statusColor(isDelivered).withAlpha(50),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              order.deliveryStatusDisplay,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.text14_400.copyWith(
                                color: _statusColor(isDelivered),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!isDelivered) ...[
                        Text(
                          AppLocaleKey.startAtDate.tr(),
                          style: AppTextStyle.text14_400.copyWith(
                            color: AppColor.redColor,
                          ),
                        ),
                        Text(
                          order.startDate ?? '',
                          style: AppTextStyle.text14_400.copyWith(
                            color: AppColor.redColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(bool isDelivered) {
    return isDelivered ? AppColor.mainAppColor : AppColor.textGrayColor;
  }

  void _onTap(BuildContext context) {
    if (_isDone) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OldOrderScreen(ordersDate: order),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CurrentOrderScreen(
            ordersDate: order,
            orderId: order.id ?? 0,
          ),
        ),
      );
    }
  }
}
