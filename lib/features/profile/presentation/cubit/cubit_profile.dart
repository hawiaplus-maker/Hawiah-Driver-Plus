import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/locale/app_locale_key.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/profile/presentation/cubit/state_profile.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/question_model.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_info_model.dart';
import 'package:hawiah_driver/features/profile/presentation/screens/model/user_profile_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserProfileModel? _user;
  UserProfileModel? get user => _user;

  UserInfoModel? _userInfo;
  UserInfoModel? get userInfo => _userInfo;

  /// Loads the session user via `GET /service-providers/user-info`.
  ///
  /// This is the app-entry access gate, not just a data fetch: a stored token
  /// only proves that a session existed once, while the account may have been
  /// deactivated since then. Entry is allowed only when the endpoint succeeds,
  /// returns the user and marks the account as active. Inactive accounts are
  /// logged out locally so the stale token can't be reused.
  ///
  /// Every outcome reports through exactly one callback, so the splash screen
  /// can never stay waiting on a response branch that wasn't handled.
  Future<void> fetchUserInfo({
    VoidCallback? onSuccess,
    ValueChanged<String>? onDenied,
    ValueChanged<String>? onError,
  }) async {
    log('============================= Fetch User Info ==============================');
    emit(ProfileLoading());

    try {
      final response = await ApiHelper.instance.get(Urls.userInfo);

      if (response.state == ResponseState.complete) {
        final raw = response.data;
        if (raw is Map) {
          final info = UserInfoModel.fromJson(Map<String, dynamic>.from(raw));
          _userInfo = info;

          if (info.canUseApp) {
            final data = info.data!;
            // Keep the work-type flags in sync with the server on every start.
            HiveMethods.updateOrderWork(data.orderWork);
            HiveMethods.updateProjectWork(data.projectWork);
            HiveMethods.updateCleaningContractWork(data.cleaningContractWork);
            // Populate the shared profile user if it wasn't fetched yet. The
            // splash no longer calls fetchProfile, so screens reading
            // `cubit.user` (e.g. chat, profile) would otherwise hit a null user.
            _user ??= UserProfileModel(
              id: data.id,
              name: data.name,
              username: '',
              mobile: data.mobile,
              email: data.email,
              city: '',
              nationalId: '',
              walletLimit: '',
              image: data.image,
            );
            emit(ProfileUserInfoLoaded(info));
            log('User info loaded: id=${data.id}, name=${data.name}');
            onSuccess?.call();
            return;
          }

          // A successful HTTP call doesn't mean the account can use the app.
          // Prefer the API message when it explains the refusal, otherwise use
          // the localized inactive-account message.
          final message = !info.success && info.message.isNotEmpty ? info.message : tr(AppLocaleKey.accountInactive);
          log('User access denied: $message');
          _clearSession();
          emit(ProfileAccessDenied(message));
          onDenied?.call(message);
          return;
        }

        final message = tr(AppLocaleKey.anErrorOccurred);
        emit(ProfileError(message));
        onError?.call(message);
        return;
      }

      if (response.state == ResponseState.unauthorized) {
        _clearSession();
        emit(ProfileUnAuthorized());
        final message = tr(AppLocaleKey.sessionExpired);
        onError?.call(message);
        return;
      }

      final message = response.getMessage().isNotEmpty ? response.getMessage() : tr(AppLocaleKey.anErrorOccurred);
      emit(ProfileError(message));
      onError?.call(message);
    } catch (e, stackTrace) {
      log("Exception in fetchUserInfo: $e", stackTrace: stackTrace);
      final message = "Failed to fetch user info: $e";
      emit(ProfileError(message));
      onError?.call(message);
    }
  }

  /// Drops the local session and any cached user data.
  void _clearSession() {
    HiveMethods.clearSession();
    _userInfo = null;
    _user = null;
  }

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
        emit(ProfileError(
            response.getMessage().isNotEmpty ? response.getMessage() : "Failed to fetch profile"));
        onError?.call();
        return;
      }
    } catch (e, stackTrace) {
      log("Exception in fetchProfile: $e", stackTrace: stackTrace);
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
      if (response.state == ResponseState.complete) {
        final message = response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.updatedSuccessfully);

        // إعادة طلب البروفايل لتحديث البيانات في الواجهة
        await fetchProfile();

        emit(ProfileUpdateSuccess(message));
      } else if (response.state == ResponseState.unauthorized) {
        emit(ProfileUnAuthorized());
      } else {
        // محاولة استخراج رسالة الخطأ
        String errorMsg = response.getMessage().isNotEmpty
            ? response.getMessage()
            : tr(AppLocaleKey.failedToUpdateData);
        emit(ProfileError(errorMsg));
      }
    } catch (e) {
      log("Update Error: $e");
      emit(ProfileError("${tr(AppLocaleKey.errorDuringUpdate)}: $e"));
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
