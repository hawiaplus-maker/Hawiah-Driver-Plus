import 'package:hawiah_driver/features/profile/presentation/screens/model/user_profile_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileModel user;
  ProfileLoaded(this.user);
}

class ProfileUpdating extends ProfileState {}

class ProfileUnAuthorized extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
