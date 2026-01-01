part of 'otp_cubit.dart';

abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpGenerateLoading extends OtpState {}

class OtpGenerateSuccess extends OtpState {
  final OtpGenerateResponse response;
  final String phone;

  OtpGenerateSuccess(this.response, this.phone);
}

class OtpGenerateError extends OtpState {
  final String message;

  OtpGenerateError(this.message);
}

class OtpInput extends OtpState {
  final String phone;

  OtpInput(this.phone);
}

class OtpVerifyLoading extends OtpState {}

class OtpVerifySuccess extends OtpState {
  final OtpVerifyResponse response;

  OtpVerifySuccess(this.response);
}

class OtpVerifyError extends OtpState {
  final String message;

  OtpVerifyError(this.message);
}




