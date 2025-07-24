import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/routes/app_routers_import.dart';

import '../theme/app_colors.dart';

class NavigatorMethods {
  static void pushNamed(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushReplacementNamed(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void showAppDialog(
    BuildContext context,
    Widget dialog, {
    bool willPop = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: willPop,
      builder: (context) {
        return PopScope(canPop: willPop, child: dialog);
      },
    );
  }

  static void showAppBottomSheet(
    BuildContext context,
    Widget bottomSheet, {
    bool willPop = true,
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: isScrollControlled,
      isDismissible: willPop,
      enableDrag: enableDrag,
      context: context,
      builder: (context) {
        return PopScope(canPop: willPop, child: bottomSheet);
      },
    );
  }

  static void loading({
    double size = 60,
    double radius = 30,
    double loadingSize = 30,
    Color? backgroundColor,
    Color? loadingColor,
  }) {
    FocusScope.of(
      AppRouters.navigatorKey.currentContext!,
    ).requestFocus(FocusNode());
    BotToast.showCustomLoading(
      toastBuilder:
          (cancelFunc) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColor.scaffoldColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Center(
              child: CustomLoading(
                color: loadingColor ?? AppColor.mainAppColor,
                size: loadingSize,
              ),
            ),
          ),
    );
  }

  static void loadingOff() {
    BotToast.closeAllLoading();
  }
}
