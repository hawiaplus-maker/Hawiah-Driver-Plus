import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/images/image_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/order/presentation/model/single_order_model.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:hawiah_driver/features/order/presentation/screens/order-otp-screen.dart';
import 'package:hawiah_driver/features/order/presentation/widget/hawiah_details.dart';
import 'package:hawiah_driver/features/order/presentation/widget/order_details_images.dart';
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
      final order = state.order;
      final support = sl<SettingCubit>().setting?.support ?? "";
      final images = order.data?.containerImages ?? <ContainerImage>[];
      final actions = _buildActions(order, support);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details, customer and images — the same sections and order as
            // the project details page.
            HawiahDetails(ordersDate: order),
            Gap(16.h),
            UserCardWidget(ordersData: order),
            if (images.isNotEmpty) ...[
              Gap(16.h),
              OrderDetailsImages(images: images),
            ],
            if (actions.isNotEmpty) ...[
              Gap(16.h),
              ...actions,
            ],
          ],
        ),
      );
    }
    return const Center(child: CustomLoading());
  }

  /// The footer of the page: the primary action, the empty-container action
  /// for status 9 and the technical support card — current orders only, in the
  /// same order as the project details page.
  List<Widget> _buildActions(SingleOrderModel order, String support) {
    final actions = <Widget>[];

    if (widget.isCurrent && !_isFinished(order)) {
      actions.add(_buildConfirmButton(order));
    }

    if (order.data?.orderStatus == 9) {
      if (actions.isNotEmpty) actions.add(Gap(16.h));
      actions.add(_buildEmptyContainerButton(order.data?.id ?? 0));
    }

    if (widget.isCurrent && support.isNotEmpty) {
      if (actions.isNotEmpty) actions.add(Gap(16.h));
      actions.add(SuppprtCardWidget(support: support));
    }

    return actions;
  }

  bool _isFinished(SingleOrderModel order) {
    final status = order.data?.status?.en;
    return status == "Delivered" || status == "Finish Order";
  }

  Widget _buildConfirmButton(SingleOrderModel order) {
    return CustomButton(
      height: 50,
      radius: 10,
      text: AppLocaleKey.confirmOrder.tr(),
      style: AppTextStyle.text14_600.copyWith(color: Colors.white),
      color: AppColor.mainAppColor,
      onPressed: () => _handleActionWithLocationAndImage(
        onProcessed: (image, lat, long) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderOtpScreen(
                otp: order.data?.otp ?? "",
                id: order.data?.id,
                image: image,
                lat: lat,
                long: long,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyContainerButton(int orderId) {
    return CustomButton(
      height: 50,
      radius: 10,
      text: AppLocaleKey.emptythecontainer.tr(),
      color: AppColor.secondAppColor,
      borderColor: AppColor.mainAppColor,
      style: AppTextStyle.text14_600.copyWith(color: AppColor.mainAppColor),
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
    // The shared service holds the position detected when the app opened.
    final locationService = sl<LocationService>();

    // 0. Check if location service is enabled first
    bool isLocationServiceEnabled =
        await locationService.checkAndRequestLocationService();
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
    // The position detected when the app opened is reused when it is still
    // fresh, so the action doesn't wait for a new GPS fix.
    final locationFuture = locationService.getLocationForAction();

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

          if (location == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocaleKey.locationUnavailable.tr()),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

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
