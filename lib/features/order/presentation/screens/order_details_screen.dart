import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/custom_widgets/global-elevated-button-widget.dart';
import 'package:hawiah_driver/core/images/image_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
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
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final bool isCurrent;

  const OrderDetailsScreen({Key? key, required this.orderId, required this.isCurrent})
      : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      bloc: context.read<OrderCubit>()..singleOrder(orderId: widget.orderId),
      builder: (context, state) {
        Widget body;

        if (state is OrderLoading) {
          body = const Center(child: CustomLoading());
        } else if (state is CurrentOrderError) {
          body = Center(child: Text(state.message));
        } else if (state is CurrentOrderLoaded) {
          final ordersData = state.order;

          final support = sl<SettingCubit>().setting?.support ?? "";
          final isDelivered = ordersData.data?.status != null &&
              ordersData.data?.status is Map &&
              (ordersData.data?.status?.en == "Delivered");
          body = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isCurrent)
                  HawiahDetails(ordersDate: ordersData)
                else
                  HawiahDetails(ordersDate: ordersData),
                const SizedBox(height: 16),
                if (widget.isCurrent)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        UserCardWidget(ordersData: ordersData),
                        SizedBox(height: 20.0),
                        if (widget.isCurrent && support.isNotEmpty)
                          SuppprtCardWidget(support: support),
                        SizedBox(height: 50.h),
                        isDelivered
                            ? SizedBox()
                            : Container(
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                child: GlobalElevatedButton(
                                  label: AppLocaleKey.confirmOrder.tr(),
                                  onPressed: () async {
                                    // Start fetching location immediately but don't block
                                    final locationFuture = LocationService().getCurrentLocation();

                                    ImageMethods.pickImage(
                                        source: ImageSource.camera,
                                        onSuccess: (image) async {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) =>
                                                const Center(child: CustomLoading()),
                                          );
                                          final location = await locationFuture;
                                          if (mounted) Navigator.pop(context);

                                          if (mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OrderOtpScreen(
                                                  otp: ordersData.data?.otp ?? "",
                                                  id: ordersData.data?.id,
                                                  image: image,
                                                  lat: location?.latitude,
                                                  long: location?.longitude,
                                                ),
                                              ),
                                            );
                                          }
                                        });
                                  },
                                  backgroundColor: AppColor.mainAppColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  borderRadius: BorderRadius.circular(10),
                                  fixedWidth: 0.80,
                                ),
                              ),
                      ],
                    ),
                  )
                else if (!widget.isCurrent)
                  UserCardWidget(ordersData: ordersData),
              ],
            ),
          );
        } else {
          body = Center(child: CustomLoading());
        }
        return Scaffold(
          appBar: CustomAppBar(
            context,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Text(AppLocaleKey.orderDetails.tr(), style: AppTextStyle.text16_700),
                const SizedBox(height: 5),
                if (state is CurrentOrderLoaded)
                  Text(
                    state.order.data?.referenceNumber.toString() ?? "",
                    style: AppTextStyle.text16_400,
                  ),
              ],
            ),
          ),
          body: body,
        );
      },
    );
  }

  void openMap(String lat, String lng) async {
    final Uri googleMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (!await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch map';
    }
  }
}
