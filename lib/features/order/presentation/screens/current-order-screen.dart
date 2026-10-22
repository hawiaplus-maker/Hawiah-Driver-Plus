import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/screens/order-otp-screen.dart';
import 'package:hawiah_driver/features/order/presentation/widget/cleaning_contract_details.dart';
import 'package:hawiah_driver/features/order/presentation/widget/project_pickup_details.dart';
import 'package:hawiah_driver/features/order/presentation/widget/support_card_widget.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/injection_container.dart';

class CurrentOrderScreen extends StatefulWidget {
  const CurrentOrderScreen(
      {Key? key,
      required this.ordersDate,
      required this.orderId})
      : super(key: key);

  /// A regular [SingleOrderData] or a [CleaningContractDeliveryItem].
  final dynamic ordersDate;
  final int orderId;
  @override
  State<CurrentOrderScreen> createState() => _CurrentOrderScreenState();
}

class _CurrentOrderScreenState extends State<CurrentOrderScreen> {
  bool get _isCleaningContract => widget.ordersDate is CleaningContractDeliveryItem;
  bool get _isProjectPickup => widget.ordersDate is ProjectDischargeItem;

  CleaningContractDeliveryItem? get _cleaning =>
      widget.ordersDate is CleaningContractDeliveryItem
          ? widget.ordersDate
          : null;

  ProjectDischargeItem? get _pickup =>
      widget.ordersDate is ProjectDischargeItem ? widget.ordersDate : null;

  SingleOrderData? get _order =>
      widget.ordersDate is SingleOrderData ? widget.ordersDate : null;

  @override
  void initState() {
    super.initState();
    if (!_isCleaningContract && !_isProjectPickup) {
      context.read<OrderCubit>().singleOrder(orderId: widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reference = _isCleaningContract
        ? _cleaning?.contractNumber
        : _isProjectPickup
            ? _pickup?.referenceNumber
            : _order?.referenceNumber;

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
            reference ?? "",
            style: AppTextStyle.text16_400,
          )
        ]),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _isCleaningContract
            ? _buildCleaningContractBody()
            : _isProjectPickup
                ? _buildProjectPickupBody()
                : _buildRegularOrderBody(),
      ),
    );
  }

  /// Project-pickup body — same structure as the typical order details:
  /// details card, client card, pickup images, support card.
  Widget _buildProjectPickupBody() {
    final support = sl<SettingCubit>().setting?.support ?? "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectPickupDetails(pickup: _pickup!),
        Gap(16.h),
        ProjectPickupClientCard(pickup: _pickup!),
        Gap(16.h),
        ProjectPickupImages(pickup: _pickup!),
        Gap(16.h),
        if (support.isNotEmpty) SuppprtCardWidget(support: support),
      ],
    );
  }

  /// Cleaning-contract body — same structure as the typical order details:
  /// details card, customer/company card, delivery images, support card.
  Widget _buildCleaningContractBody() {
    final support = sl<SettingCubit>().setting?.support ?? "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CleaningContractDetails(order: _cleaning!),
        Gap(16.h),
        CleaningContractCompanyCard(order: _cleaning!),
        Gap(16.h),
        CleaningContractDeliveryImages(order: _cleaning!),
        Gap(16.h),
        if (support.isNotEmpty) SuppprtCardWidget(support: support),
      ],
    );
  }

  /// Regular order body.
  Widget _buildRegularOrderBody() {
    final o = _order;
    if (o == null) return SizedBox.shrink();
    final isDelivered = o.status?['en'] == "Delivered";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              SizedBox(height: 20.0),
              isDelivered
                  ? SizedBox()
                  : GlobalElevatedButton(
                      label: AppLocaleKey.confirmOrder.tr(),
                      onPressed: () {
                        log(
                            "OTP =================== ${o.otp ?? ""} =================== OTP");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderOtpScreen(
                              otp: o.otp ?? "",
                              id: o.id,
                            ),
                          ),
                        );
                      },
                      backgroundColor: AppColor.mainAppColor,
                      textColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      borderRadius: BorderRadius.circular(10),
                      fixedWidth: 0.80,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
