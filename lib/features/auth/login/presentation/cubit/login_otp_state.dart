part of 'login_otp_cubit.dart';

abstract class LoginOtpState {}

class LoginOtpInitial extends LoginOtpState {}

class LoginOtpLoading extends LoginOtpState {}

class LoginOtpSuccess extends LoginOtpState {
  final LoginOtpResponse response;

  LoginOtpSuccess(this.response);
}

class LoginOtpError extends LoginOtpState {
  final String message;

  LoginOtpError(this.message);
}

