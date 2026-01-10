import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/images/image_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:hawiah_driver/features/order/presentation/screens/order-otp-screen.dart';
import 'package:hawiah_driver/features/order/presentation/widget/hawiah_details.dart';
import 'package:hawiah_driver/features/order/presentation/widget/support_card_widget.dart';
import 'package:hawiah_driver/features/order/presentation/widget/user_card_widget.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:image_picker/image_picker.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final bool isCurrent;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
    required this.isCurrent,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Move API call to initState to avoid calling it on every rebuild
    context.read<OrderCubit>().singleOrder(orderId: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(state),
          body: _buildBody(state),
        );
      },
    );
  }

  // --- UI Helpers ---

  PreferredSizeWidget _buildAppBar(OrderState state) {
    String? refNumber;
    if (state is CurrentOrderLoaded) {
      refNumber = state.order.data?.referenceNumber?.toString();
    }

    return CustomAppBar(
      context,
      centerTitle: true,
      title: Column(
        children: [
          Text(AppLocaleKey.orderDetails.tr(), style: AppTextStyle.text16_700),
          if (refNumber != null) ...[
            const SizedBox(height: 5),
            Text(refNumber, style: AppTextStyle.text16_400),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(OrderState state) {
    if (state is OrderLoading) {
      return const Center(child: CustomLoading());
    } else if (state is CurrentOrderError) {
      return Center(child: Text(state.message));
    } else if (state is CurrentOrderLoaded) {
      final ordersData = state.order;
      final support = sl<SettingCubit>().setting?.support ?? "";
      final isDelivered = ordersData.data?.status?.en == "Delivered";

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HawiahDetails(ordersDate: ordersData),
            const SizedBox(height: 16),

            // Unified styling for the information section
            widget.isCurrent
                ? _buildCurrentOrderInfo(ordersData, support, isDelivered)
                : UserCardWidget(ordersData: ordersData),

            if (ordersData.data?.containerImages?.isNotEmpty ?? false) ...[
              Text(AppLocaleKey.imagesFromDeliveryLocation.tr(), style: AppTextStyle.text16_700),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColor.mainAppColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: ordersData.data?.containerImages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final image = ordersData.data?.containerImages?[index];
                      return CustomNetworkImage(
                          radius: 5, hasZoom: true, imageUrl: image?.url ?? "");
                    },
                  ),
                ),
              ),
            ],

            // Empty container action (Order Status 9)
            if (ordersData.data?.orderStatus == 9) ...[
              const SizedBox(height: 20),
              _buildEmptyContainerButton(ordersData.data?.id ?? 0),
            ],
          ],
        ),
      );
    }
    return const Center(child: CustomLoading());
  }

  Widget _buildCurrentOrderInfo(dynamic ordersData, String support, bool isDelivered) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          UserCardWidget(ordersData: ordersData),
          if (support.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            SuppprtCardWidget(support: support),
          ],
          const SizedBox(height: 30),
          if (!isDelivered) _buildConfirmButton(ordersData),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(dynamic ordersData) {
    return GlobalElevatedButton(
      label: AppLocaleKey.confirmOrder.tr(),
      onPressed: () => _handleActionWithLocationAndImage(
        onProcessed: (image, lat, long) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderOtpScreen(
                otp: ordersData.data?.otp ?? "",
                id: ordersData.data?.id,
                image: image,
                lat: lat,
                long: long,
              ),
            ),
          );
        },
      ),
      backgroundColor: AppColor.mainAppColor,
      textColor: Colors.white,
      fixedWidth: 0.80,
    );
  }

  Widget _buildEmptyContainerButton(int orderId) {
    return CustomButton(
      text: AppLocaleKey.emptythecontainer.tr(),
      borderColor: AppColor.secondAppColor,
      onPressed: () => _handleActionWithLocationAndImage(
        onProcessed: (image, lat, long) {
          context.read<OrderCubit>().confirmEmptyOrder(
                orderId: orderId,
                lat: lat ?? 0.0,
                long: long ?? 0.0,
                img: image,
                onSuccess: () {
                  NavigatorMethods.pushReplacementNamed(
                    context,
                    LayoutScreen.routeName,
                  );
                },
              );
        },
      ),
    );
  }

  void _handleActionWithLocationAndImage({
    required Function(File image, double? lat, double? long) onProcessed,
  }) async {
    final locationService = LocationService();

    // 0. Check if location service is enabled first
    bool isLocationServiceEnabled = await locationService.checkAndRequestLocationService();
    if (!isLocationServiceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocaleKey.pleaseEnableLocation.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check permission to be safe before calling raw getLocation
    if (!await locationService.checkAndRequestLocationPermission()) {
      return;
    }

    // 1. Start fetching location immediately (async)
    // We use the raw getLocation to avoid redundant service checks
    final locationFuture = locationService.getLocation();

    // 2. Pick Image
    ImageMethods.pickImage(
      source: ImageSource.camera,
      onSuccess: (image) async {
        // 3. Show loading dialog while location finishes
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CustomLoading()),
        );

        try {
          final location = await locationFuture;

          if (mounted) Navigator.pop(context); // Pop loading dialog

          if (mounted) {
            onProcessed(image, location.latitude, location.longitude);
          }
        } catch (e) {
          if (mounted) Navigator.pop(context); // Pop loading dialog
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocaleKey.pleaseEnableLocation.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
