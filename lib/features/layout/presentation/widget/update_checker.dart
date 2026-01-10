import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:new_version_plus/model/version_status.dart';
import 'package:new_version_plus/new_version_plus.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    final newVersion = NewVersionPlus(
      androidId: "com.future.hawiah.driver.plus",
      iOSId: "1234567890",
    );

    final status = await newVersion.getVersionStatus();

    if (status == null) return;

    if (status.canUpdate) {
      _showUpdateDialog(context, status, newVersion);
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    VersionStatus status,
    NewVersionPlus newVersion,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocaleKey.updateTitle.tr()),
          content: Text(
            AppLocaleKey.updateContent.tr(
              namedArgs: {
                "store_version": status.storeVersion,
                "local_version": status.localVersion,
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocaleKey.updateLater.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                const playStoreLink =
                    "https://play.google.com/store/apps/details?id=com.future.hawiah.driver.plus";
                const appStoreLink = "https://apps.apple.com/app/id1234567890";

                final link =
                    Theme.of(context).platform == TargetPlatform.iOS ? appStoreLink : playStoreLink;

                await newVersion.launchAppStore(link);
              },
              child: Text(AppLocaleKey.updateNow.tr()),
            ),
          ],
        );
      },
    );
  }
}
