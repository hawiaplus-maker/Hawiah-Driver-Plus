import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet(
      {super.key,
      required this.title,
      required this.children,
      this.isDark = false,
      this.isLine = false});
  final String title;
  final List<Widget> children;
  final bool? isDark;
  final bool? isLine;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: isDark == true ? AppColor.blackColor : AppColor.whiteColor,
          borderRadius:
              const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                isLine == true
                    ? SizedBox()
                    : Container(
                        height: 5,
                        width: 100,
                        decoration: BoxDecoration(
                          color: isDark == true ? AppColor.hintColor : AppColor.darkGreyColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                const SizedBox(height: 15),
                ...children
              ],
            ),
          ),
        ),
      ),
    );
  }
}
