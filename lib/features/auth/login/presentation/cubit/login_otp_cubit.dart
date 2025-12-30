import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/auth/login/data/models/login_otp_response.dart';
import 'package:guess_game/features/auth/login/data/repositories/login_otp_repository.dart';

part 'login_otp_state.dart';

class LoginOtpCubit extends Cubit<LoginOtpState> {
  final LoginOtpRepository _loginOtpRepository;

  LoginOtpCubit(this._loginOtpRepository) : super(LoginOtpInitial());

  Future<void> loginWithPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    emit(LoginOtpLoading());

    final result = await _loginOtpRepository.loginWithOtp(
      phone: phone,
      otp: otp,
      loginType: 'otp',
    );

    result.fold(
      (failure) => emit(LoginOtpError(failure.message)),
      (response) => emit(LoginOtpSuccess(response)),
    );
  }

  Future<void> loginWithEmailOtp({
    required String email,
    required String otp,
  }) async {
    emit(LoginOtpLoading());

    final result = await _loginOtpRepository.loginWithEmailOtp(
      email: email,
      otp: otp,
      loginType: 'otp',
    );

    result.fold(
      (failure) => emit(LoginOtpError(failure.message)),
      (response) => emit(LoginOtpSuccess(response)),
    );
  }
}
