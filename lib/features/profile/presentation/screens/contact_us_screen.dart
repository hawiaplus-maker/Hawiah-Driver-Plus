import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';

import '../../../setting/cubit/setting_cubit.dart';
import '../../../setting/cubit/setting_state.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocaleKey.contactus.tr(),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          BlocConsumer<SettingCubit, SettingState>(
            builder: (context, state) {
              return (state is SettingUpdate)
                  ? Column(
                    children: [
                      Text(
                        '${context.read<SettingCubit>().setting?.getTouchTitle?.ar?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}',
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        '${context.read<SettingCubit>().setting?.getTouchDescription?.ar?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}',
                      ),
                      SizedBox(height: 50.h),
                      Text(
                        'mobile :${context.read<SettingCubit>().setting?.webMobiles?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}',
                      ),
                      Text(
                        'website :${context.read<SettingCubit>().setting?.webEmails?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}',
                      ),
                      Text(
                        'whatsapp :${context.read<SettingCubit>().setting?.whatsApp?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}',
                      ),
                    ],
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
