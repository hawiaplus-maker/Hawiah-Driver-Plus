import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/setting/cubit/setting_cubit.dart';

import '../../../setting/cubit/setting_state.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const routeName = '/privacy-policy-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocaleKey.privacyPolicy.tr(),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          BlocConsumer<SettingCubit, SettingState>(
            builder: (context, state) {
              return (state is SettingUpdate)
                  ? Text(
                      '${context.read<SettingCubit>().setting?.privacy?.ar?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}',
                    )
                  : (state is SettingLoading)
                      ? CircularProgressIndicator()
                      : SizedBox();
            },
            listener: (context, state) {},
          ),
        ],
      ),
    );
  }
}
