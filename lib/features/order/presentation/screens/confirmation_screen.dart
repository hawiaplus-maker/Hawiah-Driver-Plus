import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_button.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:hawiah_driver/features/layout/presentation/screens/layout-screen.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-cubit.dart';
import 'package:hawiah_driver/features/order/presentation/order-cubit/order-state.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/custom_widgets/global-elevated-button-widget.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen(
      {super.key, required this.otp, required this.id, this.image, this.lat, this.long});
  final otp;
  final id;
  final File? image;
  final double? lat;
  final double? long;
  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  bool? loading;

  Future<File?> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file =
          File('${directory.path}/confirmation_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint("Error capturing image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasLocation =
        widget.lat != null && widget.long != null && widget.lat != 0 && widget.long != 0;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrderCubit, OrderState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (widget.image != null)
                    ? RepaintBoundary(
                        key: _globalKey,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Image.file(File(widget.image!.path),
                                height: 480.w, width: 450.w, fit: BoxFit.cover),
                            if (hasLocation)
                              Container(
                                color: Colors.black54,
                                width: 450.w,
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Lat: ${widget.lat}, Long: ${widget.long}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : Container(
                        color: Colors.red,
                        height: 480.w,
                        width: 450.w,
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
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });

                              File? finalImage = widget.image;

                              // Only capture if we have location overlay
                              if (widget.image != null && hasLocation) {
                                final captured = await _capturePng();
                                if (captured != null) {
                                  finalImage = captured;
                                }
                              }

                              if (finalImage == null) {
                                setState(() {
                                  loading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 50,
                                    backgroundColor: Colors.red,
                                    content: Center(
                                      child: Text(
                                        'Error preparing image',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                context.read<OrderCubit>().confirmOrders(
                                      orderId: widget.id,
                                      otp: widget.otp,
                                      lat: widget.lat ?? 0.0,
                                      long: widget.long ?? 0.0,
                                      img: finalImage,
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
              CommonMethods.showToast(message: state.message);
              // showDialog(
              //   context: context,
              //   builder: (context) => AlertDialog(
              //     backgroundColor: AppColor.whiteColor,
              //     content: Container(
              //       height: 150.h,
              //       width: 200.h,
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //           Image.asset(AppImages.error, height: 40.h),
              //           Text(AppLocaleKey.checkTheData.tr()),
              //           GlobalElevatedButton(
              //             label: AppLocaleKey.ok.tr(),
              //             onPressed: () {
              //               Navigator.pop(context);
              //               Navigator.pop(context);
              //               Navigator.pop(context);
              //             },
              //             backgroundColor: Colors.red,
              //             textColor: Colors.white,
              //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              //             borderRadius: BorderRadius.circular(10),
              //             fixedWidth: 0.35, // 80% of the screen width
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // );
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
