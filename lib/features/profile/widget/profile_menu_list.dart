import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/images/app_images.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/utils/navigator_methods.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/faq-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/language-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/privacy-policy-screen.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/support_screen.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/terms-and-conditions.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:hawiah_driver/features/profile/widget/logout_button.dart';
import 'package:hawiah_driver/features/profile/widget/person_profile_list_tile.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key, required this.onOrderTap});
  final VoidCallback onOrderTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PersonProfileListTile(
          title: AppLocaleKey.profileFile.tr(),
          logo: AppImages.user,
          onTap: () {
            NavigatorMethods.pushNamed(context, UserProfile.routeName);
          },
        ),
        PersonProfileListTile(
          title: AppLocaleKey.support.tr(),
          logo: AppImages.handFist,
          onTap: () {
            NavigatorMethods.pushNamed(context, SupportScreen.routeName);
          },
        ),
        PersonProfileListTile(
          title: AppLocaleKey.frequentlyAskedQuestions.tr(),
          logo: AppImages.shield,
          onTap: () {
            NavigatorMethods.pushNamed(context, FaqScreen.routeName);
          },
        ),
        PersonProfileListTile(
          title: AppLocaleKey.langApp.tr(),
          logo: AppImages.earth,
          onTap: () {
            NavigatorMethods.pushNamed(context, LanguageScreen.routeName);
          },
        ),
        PersonProfileListTile(
            title: AppLocaleKey.privacyPolicy.tr(),
            logo: AppImages.fileLock,
            onTap: () {
              NavigatorMethods.pushNamed(context, PrivacyPolicyScreen.routeName);
            }),
        PersonProfileListTile(
            title: AppLocaleKey.termsAndConditions.tr(),
            logo: AppImages.handshake,
            onTap: () {
              NavigatorMethods.pushNamed(context, TermsAndConditionsScreen.routeName);
            }),
        const LogoutButton(),
      ],
    );
  }
}
