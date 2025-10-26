import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/controllers/on-boarding-cubit/on-boarding-state.dart';
import 'package:hawiah_driver/features/on-boarding/presentation/model/on_boarding_model.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  static OnBoardingCubit get(BuildContext context) => BlocProvider.of(context);

  OnBoardingCubit() : super(OnBoardingInitial());

  int currentIndex = 0;
  double progressValue = 0.25;
  PageController pageController = PageController(initialPage: 0);

  OnBoardingModel? onboarding;
  ApiResponse _onboardingResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get onboardingResponse => _onboardingResponse;

  List<Data> get onBoardingList => onboarding?.data ?? [];

  void changePageController(int index) {
    currentIndex = index;
    progressValue = (index + 1) / (onBoardingList.isEmpty ? 1 : onBoardingList.length);
    pageController.animateToPage(
      currentIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    emit(OnBoardingChange());
  }

  void skipPage() {
    if (onBoardingList.isNotEmpty) {
      currentIndex = onBoardingList.length - 1;
      pageController.jumpToPage(currentIndex);
      emit(OnBoardingChange());
    }
  }

  void changeRebuild() => emit(OnBoardingRebuild());

  void initialOnboarding() {
    _onboardingResponse = ApiResponse(state: ResponseState.sleep, data: null);
    onboarding = null;
    emit(OnBoardingChange());
  }

  Future<void> getOnboarding() async {
    emit(OnBoardingLoading());
    _onboardingResponse = await ApiHelper.instance.get(Urls.onBoarding);

    if (_onboardingResponse.state == ResponseState.complete) {
      try {
        onboarding = OnBoardingModel.fromJson(_onboardingResponse.data);
        emit(OnBoardingSuccess());
      } catch (e) {
        emit(OnBoardingError());
      }
    } else {
      emit(OnBoardingError());
    }
  }
}
