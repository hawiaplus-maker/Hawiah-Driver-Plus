import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/date_methods.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({super.key, required this.order});
  final SingleOrderData order;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColor.mainAppColor.withAlpha(40),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("#${order.referenceNumber ?? '---'}", style: AppTextStyle.text16_500),
              Text(order.product ?? '---', style: AppTextStyle.text14_400),
              const SizedBox(height: 5),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.remove_red_eye_outlined, color: AppColor.lightGreyColor, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    AppLocaleKey.showDetails.tr(),
                    style: AppTextStyle.text16_600.copyWith(
                        color: AppColor.mainAppColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.mainAppColor),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (order.status?['en'] != 'Finish Order' && order.status?['en'] != 'Delivered') ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child:
                      Icon(Icons.calendar_month_outlined, color: AppColor.lightGreyColor, size: 15),
                ),
              ],
              SizedBox(width: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: gtOrderStatusColor(order.status?['en'] ?? '').withAlpha(50),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          context.locale.languageCode == 'ar'
                              ? (order.status?['ar'] ?? '')
                              : (order.status?['en'] ?? ''),
                          style: AppTextStyle.text16_500.copyWith(
                            color: gtOrderStatusColor(order.status?['en'] ?? ''),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (order.status?['en'] != 'Finish Order' &&
                      order.status?['en'] != 'Delivered') ...[
                    Text(
                      AppLocaleKey.endAtDay.tr(),
                      style: AppTextStyle.text14_400.copyWith(
                        color: AppColor.redColor,
                      ),
                    ),
                    Text(
                      DateMethods.formatToFullData(
                        DateTime.tryParse(order.toDate ?? "") ?? DateTime.now(),
                      ),
                      style: AppTextStyle.text14_400.copyWith(
                        color: AppColor.redColor,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          )
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
