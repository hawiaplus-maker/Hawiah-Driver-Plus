import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_toast.dart';
import 'package:hawiah_driver/core/utils/common_methods.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class UrlLauncherMethods {
  static Future<void> launchURL(String? url,
      {bool isWhatsapp = false, bool isEmail = false}) async {
    if (url == null || url.isEmpty) return;

    Uri uri;

    if (isWhatsapp) {
      uri = Uri.parse("https://wa.me/${url.replaceAll('+', '').replaceAll(' ', '')}");
    } else if (isEmail) {
      uri = Uri.parse("mailto:$url");
    } else {
      uri = Uri.parse("tel:$url");
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: "لا يمكن فتح الرابط: $url");
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> launchInBrowser(String url) async {
    if (url.isNotEmpty) {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } else {
      CommonMethods.showToast(message: "url is empty", type: ToastType.error);
    }
  }

  static Future<void> launchInApp(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }

  static Future<void> makeMailMessage(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }

  static String _whatsAppUrl(String phone) {
    if (Platform.isAndroid) {
      return "https://wa.me/$phone";
    } else {
      return "https://api.whatsapp.com/send?phone=$phone";
    }
  }

  static Future<void> launchWhatsApp(String phoneNumber) async {
    if (!await launchUrl(
      Uri.parse(_whatsAppUrl(phoneNumber)),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch ${_whatsAppUrl(phoneNumber)}';
    }
  }

  static Future<void> launchGoogleMap(double? lat, double? long) async {
    final url = 'https://www.google.com/maps?q=$lat,$long';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
