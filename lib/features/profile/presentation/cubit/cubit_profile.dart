import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/question_model.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_profile_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserProfileModel? _user;
  UserProfileModel? get user => _user;

  Future<void> fetchProfile({VoidCallback? onSuccess, VoidCallback? onError}) async {
    emit(ProfileLoading());

    try {
      final response = await ApiHelper.instance.get(Urls.profile);

      if (response.state == ResponseState.complete && response.data != null) {
        _user = UserProfileModel.fromJson(response.data);
        emit(ProfileLoaded(_user!));
        onSuccess?.call();
        return;
      }

      if (response.state == ResponseState.unauthorized) {
        emit(ProfileUnAuthorized());
        onError?.call();
        return;
      }

      if (response.state == ResponseState.error) {
        emit(ProfileError(response.data?['message'] ?? "Failed to fetch profile"));
        onError?.call();
        return;
      }
    } catch (e) {
      emit(ProfileError("Failed to fetch profile: $e"));
      onError?.call();
    }
  }

  Future<void> updateProfile({
    required String name,
    String? mobile,
    String? email,
    File? imageFile,
    String? password,
    String? password_confirmation,
  }) async {
    log('============================= Update Profile Logic ==============================');
    emit(ProfileUpdating()); // استخدام State مخصص للتحديث إن وجد، أو Loading

    try {
      // 1. تجهيز البيانات الأساسية
      // إضافة _method: PUT ضروري جداً عند رفع الصور في Laravel/PHP
      final Map<String, dynamic> dataMap = {
        'name': name,
      };

      // 2. إضافة البيانات فقط إذا كانت موجودة لتجنب إرسال قيم فارغة
      if (mobile != null && mobile.isNotEmpty) dataMap['mobile'] = mobile;
      if (email != null && email.isNotEmpty) dataMap['email'] = email;

      if (password != null && password.isNotEmpty) {
        dataMap['password'] = password;
        dataMap['password_confirmation'] = password_confirmation;
      }

      // 3. معالجة الصورة
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        dataMap['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }

      // 4. تحويل الـ Map إلى FormData
      final formData = FormData.fromMap(dataMap);

      log("Sending Data: $dataMap");

      // 5. الإرسال كـ POST
      final response = await ApiHelper.instance.post(
        Urls.updateProfile,
        body: formData,
        hasToken: true,
        isMultipart: true,
      );

      // 6. التحقق من الاستجابة
      if (response.state == ResponseState.complete &&
          (response.data != null && response.data['message'] != null)) {
        final message = response.data['message'] ?? 'تم التحديث بنجاح';

        // إعادة طلب البروفايل لتحديث البيانات في الواجهة
        await fetchProfile();

        emit(ProfileUpdateSuccess(message));
      } else {
        // محاولة استخراج رسالة الخطأ
        String errorMsg = "فشل تحديث البيانات";
        if (response.data != null) {
          if (response.data['message'] != null) errorMsg = response.data['message'];
          if (response.data['errors'] != null) errorMsg = response.data['errors'].toString();
        }
        emit(ProfileError(errorMsg));
      }
    } catch (e) {
      log("Update Error: $e");
      emit(ProfileError("حدث خطأ أثناء التحديث: $e"));
    }
  }

  // أسئلة
  ApiResponse _questionsResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get questionsResponse => _questionsResponse;

  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;

  Future<void> getQuestions() async {
    if (_questions.isNotEmpty) {
      emit(ProfileLoadedQuestions(_questions));
      return;
    }

    emit(ProfileLoading());
    _questionsResponse = ApiResponse(state: ResponseState.loading, data: null);

    try {
      final response = await ApiHelper.instance.get(Urls.questions);
      _questionsResponse = response;

      if (response.state == ResponseState.complete && response.data != null) {
        _questions = questionModelFromJson(jsonEncode(response.data));
        emit(ProfileLoadedQuestions(_questions));
      } else if (response.state == ResponseState.unauthorized) {
        emit(ProfileUnAuthorized());
      } else {
        emit(ProfileError("Failed to fetch questions"));
      }
    } catch (e) {
      emit(ProfileError("Error fetching questions: $e"));
    }
  }
}
