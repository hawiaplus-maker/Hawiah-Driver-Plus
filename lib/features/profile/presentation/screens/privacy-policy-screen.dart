import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/authentication/presentation/bottom_sheet/privacy_bottom_sheet.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';
import 'package:hawiah_driver/injection_container.dart';

import '../../../setting/cubit/setting_state.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const routeName = '/privacy-policy-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context, titleText: AppLocaleKey.privacyPolicy.tr()),
      body: BlocBuilder<SettingCubit, SettingState>(
          bloc: sl<SettingCubit>(),
          builder: (context, state) {
            final setting = sl<SettingCubit>().setting;
            if (setting == null) return const Center(child: CustomLoading());
            return Column(
              children: [
                PrivacyBottomSheet(
                  isLine: true,
                  privacy: context.locale.languageCode == 'ar'
                      ? setting.privacy?.ar ?? ""
                      : setting.privacy?.en ?? "",
                ),
              ],
            );
          }),
    );
  }
}
