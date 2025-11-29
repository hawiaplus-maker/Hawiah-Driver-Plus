import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/app_hawiah_driver_plus.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-state.dart';

class LanguageScreen extends StatelessWidget {
  static const String routeName = '/language-screen';
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLanguageCubit = BlocProvider.of<AppLanguageCubit>(context);

    return Scaffold(
      appBar: CustomAppBar(
        context,
        titleText: AppLocaleKey.langApp.tr(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: BlocBuilder<AppLanguageCubit, AppLanguageState>(
          builder: (context, state) {
            final selectedLang = context.read<AppLanguageCubit>().languageSelected;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLanguageItem(
                  language: "arabic",
                  title: AppLocaleKey.arabic.tr(),
                  logo: 'assets/icons/flag_saudi_arabia_icon.png',
                  isSelected: selectedLang == "arabic",
                  onTap: () => _changeLanguage(context, appLanguageCubit, "arabic"),
                ),
                Divider(color: Colors.grey.shade300),
                _buildLanguageItem(
                  language: "english",
                  title: AppLocaleKey.english.tr(),
                  logo: 'assets/icons/flag_united_kingdom_icon.png',
                  isSelected: selectedLang == "english",
                  onTap: () => _changeLanguage(context, appLanguageCubit, "english"),
                ),
                Divider(color: Colors.grey.shade300),
                _buildLanguageItem(
                  language: "urdu",
                  title: "Urdu".tr(),
                  logo: 'assets/images/world.png',
                  isSelected: selectedLang == "urdu",
                  onTap: () => _changeLanguage(context, appLanguageCubit, "urdu"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required String language,
    required String title,
    required String logo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Radio<String>(
            value: language,
            groupValue: isSelected ? language : null,
            onChanged: (_) => onTap(),
            activeColor: AppColor.mainAppColor,
          ),
          Image.asset(logo, height: 26.h, width: 26.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    AppLanguageCubit cubit,
    String language,
  ) async {
    cubit.changeLanguage(language: language);

    if (language == "arabic") {
      await context.setLocale(const Locale("ar"));
    } else if (language == "english") {
      await context.setLocale(const Locale("en"));
    } else if (language == "urdu") {
      await context.setLocale(const Locale("ur"));
    }

    cubit.changeRebuild();
    HawiahPlusDriverApp.setMyAppState(context);
  }
}
