import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_profile_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  late UserProfileModel user;

  Future<void> fetchProfile({
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    emit(ProfileLoading());
    try {
      final response = await ApiHelper.instance.get("${Urls.profile}");

      if (response.state == ResponseState.complete) {
        user = UserProfileModel.fromJson(
          response.data,
        ); // Access 'message' from response
        log("Profile fetched successfully");
        emit(ProfileLoaded(user)); // Only emit once
        onSuccess?.call(); // Call success callback after state emission
      } else if (response.state == ResponseState.error ||
          response.state == ResponseState.unauthorized) {
        log("Profile fetch failed: ${response.data}");

        emit(
          ProfileError(response.data['message'] ?? "Failed to fetch profile"),
        );
        emit(ProfileUnAuthorized());
        onError?.call(); // Call error callback after state emission
      }
    } catch (e) {
      log("Profile fetch error: $e");
      emit(ProfileError("Failed to fetch profile: $e"));
      onError?.call(); // Call error callback on exception
    }
  }

  Future<void> updateProfile({
    required String name,
    String? mobile,
    File? imageFile,
    String? password,
    String? password_confirmation,
  }) async {
    emit(ProfileLoading());

    try {
      final data = <String, dynamic>{
        'name': name,
        'mobile': mobile,

        'password': password,
        'password_confirmation': password_confirmation,
      };

      // لو فيه صورة، أضفها كـ MultipartFile
      if (imageFile != null) {
        data['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: "profile.jpg",
        );
      }

      final formData = FormData.fromMap(data);

      final response = await ApiHelper.instance.post(
        Urls.updateProfile,
        body: formData,
        hasToken: true,
        isMultipart: true, // ← مهم
      );

      if (response.data != null && response.data['message'] != null) {
        final message = response.data['message'];

        // إعادة تحميل البيانات بعد التحديث

        // emit(ProfileLoaded(user));
        emit(ProfileUpdateSuccess(message));
        await fetchProfile();
      } else {
        emit(ProfileError("فشل تحديث البيانات"));
      }
    } catch (e) {
      emit(ProfileError("حدث خطأ أثناء التحديث: $e"));
    }
  }
}
