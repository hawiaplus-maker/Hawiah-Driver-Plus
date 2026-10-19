import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/features/app-language/presentation/controllers/app-language-cubit/app-language-cubit.dart';
import 'package:hawiah_driver/features/app-language/presentation/widgets/floating-action-button-widget.dart';
import 'package:hawiah_driver/features/app-language/presentation/widgets/language-list-view-widget.dart';

import '../controllers/app-language-cubit/app-language-state.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key, this.isOnBoarding = true});
  final bool isOnBoarding;
  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocale();
    });
  }

  Future<void> _initializeLocale() async {
    if (!_localeInitialized && mounted) {
      _localeInitialized = true;
      final cubit = context.read<AppLanguageCubit>();
      await cubit.initializeLocale(context);
      
      // Update the UI to reflect the current locale
      final currentLocale = context.locale.languageCode;
      String languageName;
      switch (currentLocale) {
        case 'ar':
          languageName = 'arabic';
          break;
      case 'en':
        languageName = 'english';
        break;
      case 'ur':
        languageName = 'urdu';
        break;
      default:
        languageName = 'english';
      }
      cubit.changeLanguage(language: languageName, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppLanguageCubit, AppLanguageState>(
      listener: (context, state) {
        // Handle any side effects or show loading/error states if needed
      },
      builder: (context, state) {
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          appBar: CustomAppBar(
            context,
            titleText: "app_language".tr(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //   LanguageDescriptionWidget(),
                LanguageListViewWidget(),
                SizedBox(height: 60.h),
              ],
            ),
          ),
          floatingActionButton: widget.isOnBoarding ? FloatingActionButtonWidget() : null,
        );
      },
    );
  }
}
