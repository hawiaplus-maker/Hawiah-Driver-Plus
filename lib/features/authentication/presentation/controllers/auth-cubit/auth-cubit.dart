import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hawiah_driver/core/hive/hive_methods.dart';
import 'package:hawiah_driver/core/networking/api_helper.dart';
import 'package:hawiah_driver/core/networking/urls.dart';
import 'package:hawiah_driver/features/authentication/presentation/controllers/auth-cubit/auth-state.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AuthCubit extends Cubit<AuthState> {
  // To access the Cubit instance from anywhere in the widget tree.
  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  AuthCubit() : super(AuthInitial());

  // Default phone number details
  PhoneNumber fullNumber = PhoneNumber(
    isoCode: 'SA',
  ); // Default country code (SA)
  String phoneNumber = '';

  // For managing password
  String passwordLogin = '';
  bool passwordVisibleLogin = false;

  // Account types (personal or business)
  List<String> accountTypes = ["personal_account", "business_account"];
  int selectedAccountType = 0; // Default to personal account

  // Terms and conditions check value
  bool checkedValueTerms = true;

  // SMS or WhatsApp selection
  int selectedSmsOrWhatsApp = 1; // Default to SMS

  // Receive notifications toggle
  bool receiveNotifications = false;

  // Update the selected SMS or WhatsApp method
  void updateSelectedSmsOrWhatsApp(int index) {
    selectedSmsOrWhatsApp = index;
    emit(AuthChange());
  }

  // Update the "receive notifications" flag
  void updateReceiveNotifications(bool newValue) {
    receiveNotifications = newValue;
    emit(AuthChange());
  }

  // Update the "terms and conditions" checkbox
  void updateCheckedValueTerms(bool newValue) {
    checkedValueTerms = newValue;
    emit(AuthChange());
  }

  // Update the selected account type (personal or business)
  void updateSelectedAccountType(int index) {
    selectedAccountType = index;
    emit(AuthChange());
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    passwordVisibleLogin = !passwordVisibleLogin;
    emit(AuthChange());
  }

  // Update the password field
  void updatePassword(String newPassword) {
    passwordLogin = newPassword;
    emit(AuthChange());
  }

  // Update phone number and trigger state change
  void onPhoneNumberChange({required PhoneNumber number}) {
    phoneNumber = number.phoneNumber!;
    emit(AuthChange());
  }

  // Flag to track timer completion
  late Timer timer;
  int remainingTime = 30;
  bool isTimerCompleted = false;
  bool showInvalidCodeMessage = false;

  void resetInvalidCodeMessage() {
    showInvalidCodeMessage = false;
    emit(AuthChange());
  }

  // Start the timer
  void startTimer() {
    isTimerCompleted = false;
    showInvalidCodeMessage = false; // Reset message
    remainingTime = 30;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
        emit(
          AuthTimerState(remainingTime: remainingTime, isTimerCompleted: false),
        );
      } else {
        isTimerCompleted = true;
        showInvalidCodeMessage = true;
        timer.cancel();
        emit(AuthTimerState(remainingTime: 0, isTimerCompleted: true));
      }
    });
  }

  // Resend the code and reset the timer

  @override
  Future<void> close() {
    timer.cancel();
    return super.close();
  }

  GlobalKey<FormState> formKeyCompleteProfile = GlobalKey<FormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyRegister = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordControllerCompleteProfile =
      TextEditingController();
  TextEditingController confirmPasswordControllerCompleteProfile =
      TextEditingController();
  TextEditingController PhoneController = TextEditingController();
  TextEditingController phoneControllerRegister = TextEditingController();
  String nameCompleteProfile = '';
  String emailCompleteProfile = '';
  String usernameCompleteProfile = '';
  String passwordCompleteProfile = '';
  bool passwordVisibleCompleteProfile = false;
  String confirmPasswordCompleteProfile = '';
  List<String> genders = ['male', 'female'];
  String? selectedGender;
  List<String> accountTypesCompleteProfile = ["company"];
  String? selectedAccountTypeCompleteProfile;
  int currentStepCompleteProfile = 0;

  String commercialRegistrationNumber = '';
  String tax_number = '';
  String municipal_license = '';
  String transport_license = '';
  void updateCurrentStepCompleteProfile(int index) {
    currentStepCompleteProfile = index;
    emit(AuthChange());
  }

  void updateSelectedAccountTypeCompleteProfile(String value) {
    selectedAccountTypeCompleteProfile = value;
    emit(AuthChange());
  }

  void updateSelectedGender(String value) {
    selectedGender = value;
    emit(AuthChange());
  }

  void togglePasswordVisibilityCompleteProfile() {
    passwordVisibleCompleteProfile = !passwordVisibleCompleteProfile;
    emit(AuthChange());
  }

  PhoneNumber fullNumberResetPassword = PhoneNumber(
    isoCode: 'SA',
  ); // Default country code (SA)
  String phoneNumberResetPassword = '';
  bool isResetPassword = false;

  String passwordReset = '';
  String passwordConfirmReset = '';
  bool passwordVisibleReset = false;

  void togglePasswordVisibilityReset() {
    passwordVisibleReset = !passwordVisibleReset;
    emit(AuthChange());
  }

  final List<PasswordCriteria> listPasswordCriteria = [
    PasswordCriteria(description: "contains8Characters", isValid: true),
    PasswordCriteria(description: "containsAtLeast1Number", isValid: true),
    PasswordCriteria(description: "containsAtLeast1Uppercase", isValid: true),
    PasswordCriteria(description: "containsAtLeast1Symbol", isValid: false),
  ];

  ///**************************************login*********************** */
  Future<void> login({
    required String? phoneNumber,
    required String? password,
    required String? fcmToken,
  }) async {
    emit(AuthLoading());

    final body = FormData.fromMap({
      'password': password,
      'mobile': phoneNumber,
      'fcm_token': fcmToken,
    });

    final response = await ApiHelper.instance.post(
      Urls.login,
      body: body,
      hasToken: false,
    );

    if (response.state == ResponseState.complete &&
        response.data['success'] == true) {
      final data = response.data['data'];
      final message = response.data['message'] ?? 'Login completed';

      if (data != null) {
        HiveMethods.updateToken(data['api_token']);

        emit(AuthSuccess(message: message));
      } else {
        emit(AuthError(message));
      }
    } else if (response.state == ResponseState.unauthorized) {
      emit(AuthError(response.data['message'] ?? "بيانات الدخول غير صحيحة"));
    } else if (response.state == ResponseState.error) {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    } else if (response.state == ResponseState.offline) {
      emit(AuthError("لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    }
  }

  ///******************Register*********************** */
  ///
  Future<void> register({
    required String? phoneNumber,
    required String? type,
  }) async {
    emit(AuthLoading());

    final body = FormData.fromMap({'type': type, 'mobile': phoneNumber});

    final response = await ApiHelper.instance.post(
      Urls.register,
      body: body,
      hasToken: false,
    );

    if (response.state == ResponseState.complete &&
        response.data['success'] == true) {
      final data = response.data['data'];
      final message = response.data['message'] ?? 'Login completed';

      if (data != null) {
        emit(
          AuthSuccess(
            message: message,
            data: response.data['data'] as Map<String, dynamic>,
          ),
        );
      } else {
        emit(AuthError(message));
      }
    } else if (response.state == ResponseState.unauthorized) {
      emit(AuthError(response.data['message'] ?? "بيانات الدخول غير صحيحة"));
    } else if (response.state == ResponseState.error) {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    } else if (response.state == ResponseState.offline) {
      emit(AuthError("لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    }
  }

  ///**************************************otp*********************** */
  Future<void> otp({required String? phoneNumber, required int? otp}) async {
    emit(AuthLoading());

    final body = FormData.fromMap({'otp': otp, 'mobile': phoneNumber});

    final response = await ApiHelper.instance.post(
      Urls.verify,
      body: body,
      hasToken: false,
    );

    if (response.state == ResponseState.complete &&
        response.data['success'] == true) {
      final data = response.data['data'];
      final message = response.data['message'] ?? 'Login completed';

      if (data != null) {
        HiveMethods.updateToken(data['user']['api_token']);
        emit(AuthSuccess(message: message));
      } else {
        emit(AuthError(message));
      }
    } else if (response.state == ResponseState.unauthorized) {
      emit(AuthError(response.data['message'] ?? "بيانات الدخول غير صحيحة"));
    } else if (response.state == ResponseState.error) {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    } else if (response.state == ResponseState.offline) {
      emit(AuthError("لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    }
  }

  //*************rend code************************** */
  Future<void> resendCodeToApi({required String? phoneNumber}) async {
    emit(AuthCodeResentLoading());

    final body = FormData.fromMap({'mobile': phoneNumber});

    final response = await ApiHelper.instance.post(
      Urls.resend,
      body: body,
      hasToken: false,
    );

    if (response.state == ResponseState.complete &&
        response.data['success'] == true) {
      final message = response.data['message'] ?? 'تم إرسال رمز التحقق مجددًا';

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      emit(AuthCodeResentSuccess(message: message));
    } else if (response.state == ResponseState.unauthorized) {
      emit(
        AuthCodeResentError(
          message: response.data['message'] ?? "بيانات غير صحيحة",
        ),
      );
    } else if (response.state == ResponseState.error) {
      emit(
        AuthCodeResentError(
          message: response.data['message'] ?? "حدث خطأ أثناء العملية",
        ),
      );
    } else if (response.state == ResponseState.offline) {
      emit(AuthCodeResentError(message: "لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    }
  }

  //*************forgot password************************** */
  Future<void> forgotPassword({required String? phoneNumber}) async {
    emit(AuthLoading());

    final body = FormData.fromMap({'mobile': phoneNumber});

    final response = await ApiHelper.instance.post(
      Urls.forgetPassword,
      body: body,
      hasToken: false,
    );

    if (response.state == ResponseState.complete &&
        response.data['success'] == true) {
      final message = response.data['message'] ?? 'تم إرسال رمز التحقق مجددًا';
      final data = response.data['data'];

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      emit(AuthSuccess(message: message, data: data));
    } else if (response.state == ResponseState.unauthorized) {
      emit(AuthError(response.data['message'] ?? "بيانات غير صحيحة"));
    } else if (response.state == ResponseState.error) {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    } else if (response.state == ResponseState.offline) {
      emit(AuthError("لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    }
  }

  //*************reset password************************** */
  Future<void> resetPassword({
    required String? phoneNumber,
    required int? otp,
    required String? password,
    required String? password_confirmation,
  }) async {
    emit(AuthLoading());
    final body = FormData.fromMap({
      'mobile': phoneNumber,
      'otp': otp,
      'password': password,
      'password_confirmation': password_confirmation,
    });
    final response = await ApiHelper.instance.post(
      Urls.resetPassword,
      body: body,
      hasToken: false,
    );
    if (response.state == ResponseState.complete &&
        response.data['success'] == true) {
      final message = response.data['message'] ?? 'تم إرسال رمز التحقق مجددًا';
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      emit(AuthSuccess(message: message));
    } else if (response.state == ResponseState.unauthorized) {
      emit(AuthError(response.data['message'] ?? "بيانات غير صحيحة"));
    } else if (response.state == ResponseState.error) {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    } else if (response.state == ResponseState.offline) {
      emit(AuthError("لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "بيانات غير صحيحة"));
    }
  }

  ///*************logout************************** */
  Future<void> logout() async {
    emit(AuthLoading());

    final response = await ApiHelper.instance.post(Urls.logout, hasToken: true);

    if (response.state == ResponseState.complete) {
      final data = response.data['data'];
      final message = response.data['message'] ?? 'Logout completed';

      if (response.state == ResponseState.complete) {
        HiveMethods.deleteToken();
        emit(AuthSuccess(message: message));
      } else if (response.state == ResponseState.unauthorized) {
        emit(AuthError(response.data['message'] ?? "تم انتهاء الجلسة"));
      } else if (response.state == ResponseState.error) {
        emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
      } else if (response.state == ResponseState.offline) {
        emit(AuthError("لا يوجد اتصال بالإنترنت"));
      } else {
        emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
      }
    }
  }

  ///*************complete profile************************** */
  Future<void> completeRegister({
    required String? phoneNumber,
    required String? name,
    required String? password,
    required String? password_confirmation,
  }) async {
    emit(AuthLoading());

    final body = FormData.fromMap({
      'name': name,
      'mobile': phoneNumber,
      'password': password,
      "password_confirmation": password_confirmation,
    });

    final response = await ApiHelper.instance.post(
      Urls.completeRegister,
      body: body,
      hasToken: false,
    );

    if (response.state == ResponseState.complete) {
      final data = response.data['data'];
      final message = response.data['message'] ?? 'Login completed';

      if (data != null) {
        emit(
          AuthSuccess(
            message: message,
            data: response.data['data'] as Map<String, dynamic>,
          ),
        );
      } else {
        emit(AuthError(message));
      }
    } else if (response.state == ResponseState.unauthorized) {
      emit(AuthError(response.data['message'] ?? "بيانات الدخول غير صحيحة"));
    } else if (response.state == ResponseState.error) {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    } else if (response.state == ResponseState.offline) {
      emit(AuthError("لا يوجد اتصال بالإنترنت"));
    } else {
      emit(AuthError(response.data['message'] ?? "حدث خطأ أثناء العملية"));
    }
  }
}

class PasswordCriteria {
  final String description;
  final bool isValid;

  // Constructor
  PasswordCriteria({required this.description, required this.isValid});
}
