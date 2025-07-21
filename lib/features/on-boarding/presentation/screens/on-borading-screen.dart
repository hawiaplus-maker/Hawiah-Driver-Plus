import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/widgets/on-boarding-appBar-widget.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/widgets/on-boarding-content-widget.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/widgets/on-boarding-page-view-widget.dart';

import '../controllers/on-boarding-cubit/on-boarding-cubit.dart';
import '../controllers/on-boarding-cubit/on-boarding-state.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    HiveMethods.updateFirstTime();
    OnBoardingCubit.get(context).getOnboarding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnBoardingCubit, OnBoardingState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = OnBoardingCubit.get(context);

          if (state is OnBoardingLoading) {
            return Center(child: CustomLoading());
          }

          if (state is OnBoardingError || cubit.onBoardingList.isEmpty) {
            return const Center(child: Text(AppLocaleKey.loadingRequests));
          }

          final currentIndex = cubit.currentIndex;
          final progressValue = cubit.progressValue;
          final pageController = cubit.pageController;

          final onBoardingImages =
              cubit.onBoardingList.map((e) => e.image ?? "").toList();
          final onboardingTitles =
              cubit.onBoardingList.map((e) => e.title ?? "").toList();
          final onboardingContents =
              cubit.onBoardingList.map((e) => e.about ?? "").toList();
          final onboardingIcons = List.generate(
            cubit.onBoardingList.length,
            (index) => "",
          );

          return Stack(
            children: [
              OnBoardingPageView(
                onBoardingImages: onBoardingImages,
                pageController: pageController,
                onPageChanged: (index) => cubit.changePageController(index),
              ),
              OnBoardingAppBar(),
              OnBoardingContent(
                currentIndex: currentIndex,
                onboardingIcons: onboardingIcons,
                onboardingTitles: onboardingTitles,
                onboardingContents: onboardingContents,
                progressValue: progressValue,
                pageController: pageController,
                totalImagesCount: onBoardingImages.length,
              ),
            ],
          );
        },
      ),
    );
  }
}
