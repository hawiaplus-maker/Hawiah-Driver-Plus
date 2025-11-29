import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/extension/context_extension.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';

class CustomAppBar extends PreferredSize {
  final double height;
  final double radius;
  final double elevation;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final String? titleText;
  final Color? appBarColor;
  final Color? shadowColor;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;
  final BuildContext context;
  final BorderRadiusGeometry? borderRadius;
  CustomAppBar(
    this.context, {
    super.key,
    this.height = kToolbarHeight,
    this.radius = 25,
    this.elevation = 0,
    this.leading,
    this.titleText,
    this.actions,
    this.title,
    this.appBarColor,
    this.centerTitle = true,
    this.bottom,
    this.leadingWidth,
    this.shadowColor,
    this.automaticallyImplyLeading = true,
    this.borderRadius,
  }) : super(
          preferredSize: Size.fromHeight(height),
          child: AppBar(
            scrolledUnderElevation: 0,
            elevation: elevation,
            backgroundColor: appBarColor ?? Colors.white,
            toolbarHeight: height,
            automaticallyImplyLeading: automaticallyImplyLeading,
            shadowColor: shadowColor,
            centerTitle: centerTitle,
            title: title ??
                Text(
                  titleText ?? "",
                  style: AppTextStyle.text18_500.copyWith(
                    fontFamily: context.fontFamily(),
                  ),
                ),
            leading: leading ??
                (automaticallyImplyLeading && Navigator.canPop(context)
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      )
                    : const SizedBox()),
            actions: actions,
            leadingWidth: leadingWidth,
            bottom: bottom,
          ),
        );
}
