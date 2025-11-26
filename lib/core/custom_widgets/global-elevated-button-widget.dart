import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';

class GlobalElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;
  final double? fixedWidth;
  final bool isLoading;

  const GlobalElevatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF2AD352),
    this.textColor = Colors.white,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.fixedWidth = 0.80,
    this.isLoading = false, // 80% width of the screen
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed, // Disable if not enabled
      icon: icon != null ? icon : SizedBox.shrink(),
      label: isLoading
          ? CustomLoading()
          : Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        fixedSize: Size.fromWidth(fixedWidth! * MediaQuery.of(context).size.width),
      ),
    );
  }
}
