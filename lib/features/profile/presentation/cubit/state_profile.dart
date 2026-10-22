import 'package:hawiah_driver/features/profile/presentation/screens/model/question_model.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_info_model.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_profile_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileModel user;
  ProfileLoaded(this.user);
}

class ProfileUpdating extends ProfileState {}

class ProfileUserInfoLoaded extends ProfileState {
  final UserInfoModel userInfo;
  ProfileUserInfoLoaded(this.userInfo);
}

class ProfileUnAuthorized extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileLoadedQuestions extends ProfileState {
  final List<QuestionModel> questions;
  ProfileLoadedQuestions(this.questions);
}
