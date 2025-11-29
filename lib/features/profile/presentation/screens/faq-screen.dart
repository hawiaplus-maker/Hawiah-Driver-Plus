import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/theme/app_colors.dart';
import 'package:hawiah_driver/core/theme/app_text_style.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/cubit_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:hawiah_driver/features/profile/widget/custom_expandable_tile.dart';

class FaqScreen extends StatefulWidget {
  static const String routeName = '/faq-screen';
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getQuestions();
  }

  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Scaffold(
      appBar: CustomAppBar(
        context,
        titleText: locale == 'ar'
            ? AppLocaleKey.frequentlyAskedQuestions.tr()
            : 'Frequently Asked Questions',
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CustomLoading());
          } else if (state is ProfileLoadedQuestions) {
            final questions = state.questions;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final item = questions[index];
                return CustomExpandableTile(
                  title: locale == 'ar' ? item.question.ar : item.question.en,
                  children: [
                    Text(
                      locale == 'ar' ? item.answer.ar : item.answer.en,
                      style: AppTextStyle.text16_400.copyWith(color: AppColor.textGrayColor),
                    ),
                  ],
                );
              },
            );
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
