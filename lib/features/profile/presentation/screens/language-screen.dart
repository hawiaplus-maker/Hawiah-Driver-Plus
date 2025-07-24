import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';
import 'package:hawiah_driver/main.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLanguageCubit = BlocProvider.of<AppLanguageCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocaleKey.langApp.tr(),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          languageItem(
            title: AppLocaleKey.arabic.tr(),
            logo: 'assets/icons/flag_saudi_arabia_icon.png',
            onTap: () async {
              appLanguageCubit.changeLanguage(language: "arabic");
              await context.setLocale(const Locale("ar"));
              appLanguageCubit.changeRebuild();
              MyApp.setMyAppState(context);
            },
          ),
          languageItem(
            title: AppLocaleKey.english.tr(),
            logo: 'assets/icons/flag_united_kingdom_icon.png',
            onTap: () async {
              appLanguageCubit.changeLanguage(language: "english");
              await context.setLocale(const Locale("en"));
              appLanguageCubit.changeRebuild();
              MyApp.setMyAppState(context);
            },
            isHaveLine: false,
          ),
        ],
      ),
    );
  }

  Widget languageItem({
    required String title,
    required String logo,
    bool isHaveLine = true,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              children: [
                Image.asset(logo, height: 40.h, width: 40.w),
                SizedBox(width: 10.w),
                Text(title, style: TextStyle(fontSize: 14.sp, color: color)),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20.sp,
                  color: const Color(0xffA6A6A6),
                ),
              ],
            ),
          ),
          if (isHaveLine)
            Divider(color: Colors.grey, thickness: 0.5)
          else
            SizedBox.shrink(),
        ],
      ),
    );
  }
}
