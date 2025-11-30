import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';

class LanguageListViewWidget extends StatelessWidget {
  const LanguageListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appLanguageCubit = BlocProvider.of<AppLanguageCubit>(context);
    final selectedLang = appLanguageCubit.languageSelected;

    return Container(
      height: 0.4.sh,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        itemCount: appLanguageCubit.languages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final language = appLanguageCubit.languages[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: () async {
              appLanguageCubit.changeLanguage(language: language);
              if (language == "arabic") {
                await context.setLocale(const Locale("ar"));
              } else if (language == "english") {
                await context.setLocale(const Locale("en"));
              } else if (language == "Urdu") {
                await context.setLocale(
                  Locale('ur'),
                );
              }
              appLanguageCubit.changeRebuild();
            },
            title: Row(
              children: [
                Image.asset(
                  language == "arabic"
                      ? 'assets/icons/flag_saudi_arabia_icon.png'
                      : language == "english"
                          ? 'assets/icons/flag_united_kingdom_icon.png'
                          : 'assets/images/world.png',
                  height: 20.h,
                  width: 20.w,
                ),
                const SizedBox(width: 10),
                Text(
                  language.tr(),
                  style: AppTextStyle.text20_700,
                ),
              ],
            ),
            leading: Radio<String>(
              value: language,
              groupValue: selectedLang,
              onChanged: (value) async {
                appLanguageCubit.changeLanguage(language: language);
                if (language == "arabic") {
                  await context.setLocale(const Locale("ar"));
                } else if (language == "english") {
                  await context.setLocale(const Locale("en"));
                } else if (language == "Urdu") {
                  await context.setLocale(const Locale("ur"));
                }
                appLanguageCubit.changeRebuild();
              },
              activeColor: AppColor.mainAppColor,
            ),
          );
        },
      ),
    );
  }
}
