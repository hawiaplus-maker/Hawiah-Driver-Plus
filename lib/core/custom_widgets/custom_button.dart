import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final double radius;
  final double? width;
  final double height;
  final TextStyle? style;
  final String? text;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? child;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final ApiResponse? apiResponse;
  final bool isLoading;
  final bool isMainColor;
  final bool hasShadow;
  final void Function()? onPressed;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  const CustomButton({
    super.key,
    this.radius = 12,
    this.width,
    this.height = 47,
    this.style,
    this.text,
    this.prefixIcon = const SizedBox(),
    this.suffixIcon = const SizedBox(),
    this.color,
    this.gradient,
    this.apiResponse,
    this.isLoading = false,
    this.isMainColor = true,
    this.hasShadow = false,
    this.onPressed,
    this.child,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return apiResponse?.state == ResponseState.loading || isLoading
        ? const Center(
            child: CustomLoading(),
          )
        : Container(
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: color ?? (isMainColor ? AppColor.mainAppColor : AppColor.secondAppColor),
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
              border: Border.all(color: borderColor ?? Colors.transparent, width: 1.5),
              boxShadow: boxShadow ??
                  (hasShadow
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 0),
                            blurRadius: 6,
                          )
                        ]
                      : null),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...{
                          prefixIcon!,
                          const SizedBox(width: 10),
                        },
                        Flexible(
                          child: child ??
                              Text(
                                text ?? "",
                                textAlign: TextAlign.center,
                                style: style ?? AppTextStyle.buttonStyle,
                              ),
                        ),
                        if (suffixIcon != null) ...{
                          const SizedBox(width: 5),
                          suffixIcon!,
                        }
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(radius),
                      onTap: onPressed,
                      child: SizedBox(
                        width: width ?? double.infinity,
                        height: height,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
