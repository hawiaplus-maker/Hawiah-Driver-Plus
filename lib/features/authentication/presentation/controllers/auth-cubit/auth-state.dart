abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthSuccess extends AuthState {
  final String message;
  final Map<String, dynamic>? data;

  AuthSuccess({
    required this.message,
    this.data,
  });
}

class AuthLoginSuccess extends AuthSuccess {
  AuthLoginSuccess({required super.message, super.data});
}

class AuthRegisterSuccess extends AuthSuccess {
  AuthRegisterSuccess({required super.message, super.data});
}

class AuthForgotPasswordSuccess extends AuthSuccess {
  AuthForgotPasswordSuccess({required super.message, super.data});
}

class AuthOtpSuccess extends AuthSuccess {
  AuthOtpSuccess({required super.message, super.data});
}

class AuthResetPasswordSuccess extends AuthSuccess {
  AuthResetPasswordSuccess({required super.message, super.data});
}

class AuthCompleteRegisterSuccess extends AuthSuccess {
  AuthCompleteRegisterSuccess({required super.message, super.data});
}

class AuthCodeResentLoading extends AuthState {}

class AuthCodeResentSuccess extends AuthState {
  final String message;
  final Map<String, dynamic>? data;
  AuthCodeResentSuccess({required this.message, this.data});
}

class AuthCodeResentError extends AuthState {
  final String message;
  AuthCodeResentError({required this.message});
}

class AuthTimerState extends AuthState {
  final int remainingTime;
  final bool isTimerCompleted;

  AuthTimerState({required this.remainingTime, required this.isTimerCompleted});
}

class AuthChange extends AuthState {}

class AuthRebuild extends AuthState {}

class LogOutSuccess extends AuthState {
  final String message;
  final Map<String, dynamic>? data;

  LogOutSuccess({
    required this.message,
    this.data,
  });
}
