import 'package:fluttertoast/fluttertoast.dart';
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
}
