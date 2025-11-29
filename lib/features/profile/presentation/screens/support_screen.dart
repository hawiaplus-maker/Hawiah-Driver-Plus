import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/api_response_widget.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_state.dart';
import 'package:hawiah_driver/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  static const String routeName = '/support-screen';
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // @override
  // void initState() {
  //   sl<SettingCubit>().initialSetting();
  //   sl<SettingCubit>().getsetting();
  //   super.initState();
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        titleText: AppLocaleKey.support.tr(),
      ),
      body: ApiResponseWidget(
        apiResponse: sl<SettingCubit>().settingResponse,
        onReload: () => sl<SettingCubit>().getsetting(),
        isEmpty: false,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              CustomSupport(
                image: AppImages.mail,
                title: "email".tr(),
                subtitle: sl<SettingCubit>().setting?.email ?? "",
              ),
              Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              ),
              CustomSupport(
                image: AppImages.phoneSvg,
                title: "phones".tr(),
                subtitle: sl<SettingCubit>().setting?.phone ?? "",
              ),
              Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              ),
              CustomSupport(
                image: AppImages.mapPin,
                title: "map".tr(),
                subtitle: sl<SettingCubit>().setting?.address?.ar ?? "",
              ),
              BlocBuilder<SettingCubit, SettingState>(
                builder: (context, state) {
                  final setting = sl<SettingCubit>().setting;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            textAlign: TextAlign.center,
                            AppLocaleKey.socialMedia.tr(),
                            style: AppTextStyle.text16_400,
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _launchURL(setting?.whatsApp ?? "", isWhatsapp: true),
                              child: Image.asset(
                                AppImages.whatsapp,
                                height: 24,
                                width: 24,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _launchURL(setting?.facebook ?? ""),
                              child: Image.asset(AppImages.facebookIcon, height: 24, width: 24),
                            ),
                            GestureDetector(
                              onTap: () => _launchURL(setting?.twitter ?? ""),
                              child: Image.asset(AppImages.twitter, height: 24, width: 24),
                            ),
                            GestureDetector(
                              onTap: () => _launchURL(setting?.linkedIn ?? ""),
                              child: Image.asset(AppImages.linkedin, height: 24, width: 24),
                            ),
                            GestureDetector(
                              onTap: () => _launchURL(setting?.instagram),
                              child: Image.asset(AppImages.instagram, height: 24, width: 24),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          AppLocaleKey.communicateWith.tr(),
                          style: AppTextStyle.text16_400,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Text(
                          AppLocaleKey.twentyFourHoursADay.tr(),
                          style: AppTextStyle.text16_400,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String? url, {bool isWhatsapp = false, bool isEmail = false}) async {
    if (url == null || url.isEmpty) return;

    Uri uri;

    if (isWhatsapp) {
      uri = Uri.parse("https://wa.me/${url.replaceAll('+', '').replaceAll(' ', '')}");
    } else if (isEmail) {
      uri = Uri.parse("mailto:$url");
    } else {
      uri = Uri.parse(url);
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

class CustomSupport extends StatelessWidget {
  const CustomSupport({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });
  final String image;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(image, height: 24.h, width: 24.w),
      title: Text(
        title,
        style: AppTextStyle.text14_400,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyle.text18_400.copyWith(color: AppColor.mainAppColor),
      ),
    );
  }
}
