part of 'login_email_cubit.dart';

abstract class LoginEmailState {}

class LoginEmailInitial extends LoginEmailState {}

class LoginEmailLoading extends LoginEmailState {}

class LoginEmailSuccess extends LoginEmailState {
  final LoginEmailResponse response;

  LoginEmailSuccess(this.response);
}

class LoginEmailError extends LoginEmailState {
  final String message;

  LoginEmailError(this.message);
}

