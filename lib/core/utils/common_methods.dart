import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hawiah_driver/app_hawiah_driver_plus.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_select/custom_select_item.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_toast.dart';
import 'package:hawiah_driver/core/routes/app_routers_import.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../extension/context_extension.dart';
import '../hive/hive_methods.dart';
import '../locale/app_locale_key.dart';
import '../networking/api_helper.dart';
import '../theme/app_colors.dart';

class CommonMethods {
  static void showAlertDialog({
    String? title,
    required String message,
  }) {
    showCupertinoDialog(
      context: AppRouters.navigatorKey.currentContext!,
      builder: (context) => CupertinoAlertDialog(
        title: title != null
            ? Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: context.fontFamily(),
                ),
              )
            : null,
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: context.fontFamily(),
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              tr(AppLocaleKey.ok),
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: context.fontFamily(),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  static void showChooseDialog(
    BuildContext context, {
    String? title,
    required String message,
    required VoidCallback onPressed,
    Widget? child,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: title != null
            ? Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: context.fontFamily(),
                ),
              )
            : null,
        content: Column(
          children: [
            Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: context.fontFamily(),
              ),
            ),
            if (child != null) ...{
              const Gap(10),
              child,
            }
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              tr(AppLocaleKey.no),
              style: TextStyle(
                color: AppColor.textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: context.fontFamily(),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            onPressed: onPressed,
            child: Text(
              tr(AppLocaleKey.yes),
              style: TextStyle(
                color: AppColor.textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: context.fontFamily(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showLoginFirstDialog(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    if (HiveMethods.getToken() != null) {
      onPressed.call();
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Text(
            tr(AppLocaleKey.pleaseLoginFirst),
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: context.fontFamily(),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                tr(AppLocaleKey.cancel),
                style: TextStyle(
                  color: AppColor.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: context.fontFamily(),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              onPressed: () {
                // NavigatorMethods.pushNamedAndRemoveUntil(
                //   context,
                //   LoginScreen.routeName,
                // );
              },
              child: Text(
                tr(AppLocaleKey.login),
                style: TextStyle(
                  color: AppColor.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: context.fontFamily(),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  static void showToast({
    required String message,
    String? title,
    String? icon,
    ToastType type = ToastType.success,
    Color? backgroundColor,
    Color? textColor,
    int seconds = 3,
  }) {
    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      toastBuilder: (cancelFunc) => CustomToast(
        type: type,
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        textColor: textColor,
      ),
    );
  }

  static void showError({
    ApiResponse? apiResponse,
    required String message,
    String? title,
    String? icon,
    Color? backgroundColor,
    Color? textColor,
    int seconds = 3,
  }) {
    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      toastBuilder: (context) => CustomToast(
        title: title,
        message: message,
        type: apiResponse?.state == ResponseState.offline ? ToastType.offline : ToastType.error,
        backgroundColor: backgroundColor,
        icon: icon,
        textColor: textColor,
      ),
    );
  }

  static Future<bool> hasConnection() async {
    var checker = InternetConnectionChecker.instance;
    bool isConnected = await checker.hasConnection;
    if (isConnected) {
      return true;
    } else {
      return false;
    }
  }

  static List<CustomSelectItem> dropdownMenuItems = [
    ...List.generate(
      20,
      (index) => {
        'id': index,
        'value': AppRouters.navigatorKey.currentContext!.apiTr(
          ar: 'العنصر ${index + 1}',
          en: 'Item ${index + 1}',
        ),
      },
    ),
  ]
      .map(
        (e) => CustomSelectItem(
          value: int.tryParse(e['id'].toString()),
          name: e['value']?.toString() ?? "",
        ),
      )
      .toList();

  static void changeLanguage(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          tr(AppLocaleKey.language),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: context.fontFamily(),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              HiveMethods.updateLang(const Locale('ar'));
              context.setLocale(const Locale('ar'));
              onTap.call();
              HawiahPlusDriverApp.setMyAppState(context);
              Navigator.pop(context);
            },
            child: Text(
              'العربية',
              style: TextStyle(
                fontFamily: context.fontFamilyAr(),
                color: context.locale == const Locale('ar')
                    ? AppColor.mainAppColor
                    : AppColor.textPrimaryColor,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              HiveMethods.updateLang(const Locale('en'));
              context.setLocale(const Locale('en'));
              onTap.call();
              HawiahPlusDriverApp.setMyAppState(context);
              Navigator.pop(context);
            },
            child: Text(
              'English',
              style: TextStyle(
                fontFamily: context.fontFamilyEn(),
                color: context.locale == const Locale('en')
                    ? AppColor.mainAppColor
                    : AppColor.textPrimaryColor,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            tr(AppLocaleKey.cancel),
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: context.fontFamily(),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  static bool endScroll(ScrollEndNotification t, VoidCallback onEnd) {
    if (t.metrics.pixels > 0 && t.metrics.atEdge) {
      onEnd.call();
    }
    return true;
  }
}
