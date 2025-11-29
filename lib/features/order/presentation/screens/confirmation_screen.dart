import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';
import 'package:hawiah_driver/features/location/service/location_service.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import '../../../../core/custom_widgets/global-elevated-button-widget.dart';
import '../../../../core/images/app_images.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key, required this.otp, required this.id});
  final otp;
  final id;
  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    getLocation();
    super.initState();
  }

  getLocation() async {
    location = await LocationService().getCurrentLocation();
  }

  XFile? image;
  LocationData? location;
  bool? loading;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrderCubit, OrderState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (image != null)
                    ? Image.file(File(image!.path), height: 480.w, width: 450.w)
                    : Column(
                        children: [
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black, width: 5.h),
                              ),
                              child: Image.asset(
                                AppImages.carPickerIcon,
                                height: 150.h,
                                width: 200.w,
                                fit: BoxFit.fill,
                              ),
                            ),
                            onTap: () async {
                              image = await ImagePicker().pickImage(source: ImageSource.camera);
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            AppLocaleKey.attachAPicture.tr(),
                            style: TextStyle(color: Colors.black, fontSize: 18.sp),
                          ),
                        ],
                      ),
                SizedBox(height: 50.h),
                Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: (loading != true)
                      ? Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: CustomButton(
                            text: AppLocaleKey.confirm.tr(),
                            onPressed: () {
                              if (location == null || image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 50,
                                    backgroundColor: Colors.red,
                                    content: Center(
                                      child: Text(
                                        'please check your data and try again',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                context.read<OrderCubit>().confirmOrders(
                                      orderId: widget.id,
                                      otp: widget.otp,
                                      lat: location!.latitude,
                                      long: location!.longitude,
                                      img: File(image!.path),
                                    );
                              }
                            },
                          ),
                        )
                      : CustomLoading(),
                ),
              ],
            );
          },
          listener: (BuildContext context, state) {
            if (state is OrderConfirmed) {
              loading = false;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColor.whiteColor,
                  content: Container(
                    height: 150.h,
                    width: 200.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Image.asset(AppImages.confirmed, height: 40.h),
                        Text(AppLocaleKey.confirmedSuccessfully.tr()),
                        GlobalElevatedButton(
                          label: AppLocaleKey.ok.tr(),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LayoutScreen(isRefreshOrders: true),
                              ),
                              (route) => false,
                            );
                          },
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          borderRadius: BorderRadius.circular(10),
                          fixedWidth: 0.35, // 80% of the screen width
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is OrderError) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColor.whiteColor,
                  content: Container(
                    height: 150.h,
                    width: 200.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(AppImages.error, height: 40.h),
                        Text(AppLocaleKey.checkTheData.tr()),
                        GlobalElevatedButton(
                          label: AppLocaleKey.ok.tr(),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          borderRadius: BorderRadius.circular(10),
                          fixedWidth: 0.35, // 80% of the screen width
                        ),
                      ],
                    ),
                  ),
                ),
              );
              loading = false;
            } else if (state is OrderLoading) {
              loading = true;
            } else {
              loading = false;
            }
          },
        ),
      ),
    );
  }
}
