import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/order/presentation/model/cleaning_contract_delivery_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/orders_model.dart';
import 'package:hawiah_driver/features/order/presentation/model/project_discharge_model.dart';
import 'package:hawiah_driver/features/order/presentation/widget/cleaning_contract_details.dart';
import 'package:hawiah_driver/features/order/presentation/widget/project_pickup_details.dart';

class OldOrderScreen extends StatefulWidget {
  const OldOrderScreen({Key? key, required this.ordersDate}) : super(key: key);

  /// A regular [SingleOrderData], a [CleaningContractDeliveryItem] or a
  /// [ProjectDischargeItem].
  final dynamic ordersDate;

  @override
  State<OldOrderScreen> createState() => _OldOrderScreenState();
}

class _OldOrderScreenState extends State<OldOrderScreen> {
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
  Widget build(BuildContext context) {
    final double totalPrice = _isCleaningContract || _isProjectPickup
        ? 0.0
        : (double.tryParse(_order?.totalPrice ?? "0") ?? 0);
    final double vat = totalPrice * 0.15;
    final double netTotal = totalPrice + vat;

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
                : _buildRegularOrderBody(
                    totalPrice: totalPrice,
                    vat: vat,
                    netTotal: netTotal,
                  ),
      ),
    );
  }

  /// Project-pickup body (completed) — typical structure: details card
  /// (with completed status badge and completion date), client card, images.
  Widget _buildProjectPickupBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectPickupDetails(pickup: _pickup!),
        Gap(16.h),
        ProjectPickupClientCard(pickup: _pickup!),
        Gap(16.h),
        ProjectPickupImages(pickup: _pickup!),
      ],
    );
  }

  /// Cleaning-contract body — same structure as the typical old order details:
  /// details card (with delivered status badge and delivery date),
  /// customer/company card and delivery images.
  Widget _buildCleaningContractBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CleaningContractDetails(order: _cleaning!),
        Gap(16.h),
        CleaningContractCompanyCard(order: _cleaning!),
        Gap(16.h),
        CleaningContractDeliveryImages(order: _cleaning!),
      ],
    );
  }

  /// Regular order body.
  Widget _buildRegularOrderBody({
    required double totalPrice,
    required double vat,
    required double netTotal,
  }) {
    final o = _order;
    if (o == null) return SizedBox.shrink();
    final statusText = o.status?['en'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocaleKey.name.tr()} ${o.user ?? ""}',
          style: AppTextStyle.text16_700,
        ),
        Gap(20.h),
        if (o.product != null) ...[
          Text(
            AppLocaleKey.product.tr(),
            style: AppTextStyle.text16_700,
          ),
          Gap(8.h),
          Text(o.product ?? '', style: AppTextStyle.text16_400),
          Gap(16.h),
        ],
        if (o.address != null) ...[
          Text(
            AppLocaleKey.address.tr(),
            style: AppTextStyle.text16_700,
          ),
          Gap(8.h),
          Text(o.address ?? '', style: AppTextStyle.text16_400),
          Gap(16.h),
        ],
        if (o.createdAt != null) ...[
          Text(
            AppLocaleKey.createdAt.tr(),
            style: AppTextStyle.text16_700,
          ),
          Gap(8.h),
          Text(o.createdAt ?? '', style: AppTextStyle.text16_400),
          Gap(16.h),
        ],
        Text(
          '${AppLocaleKey.totalPrice.tr()} ${totalPrice.toStringAsFixed(2)}',
          style: AppTextStyle.text16_700,
        ),
        Text(
          '${AppLocaleKey.tax.tr()} ${vat.toStringAsFixed(2)}',
          style: AppTextStyle.text16_500,
        ),
        Text(
          '${AppLocaleKey.netTotal.tr()} ${netTotal.toStringAsFixed(2)}',
          style: AppTextStyle.text16_700,
        ),
        if (statusText.isNotEmpty) ...[
          Text(
            '${AppLocaleKey.deliveryStatus.tr()}: $statusText',
            style: AppTextStyle.text16_500,
          ),
        ],
      ],
    );
  }
}
