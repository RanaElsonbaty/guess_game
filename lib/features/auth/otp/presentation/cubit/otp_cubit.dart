import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/auth/otp/data/models/otp_generate_response.dart';
import 'package:guess_game/features/auth/otp/data/models/otp_verify_response.dart';
import 'package:guess_game/features/auth/otp/data/repositories/otp_repository.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository _otpRepository;

  OtpCubit(this._otpRepository) : super(OtpInitial());

  Future<void> generateOtp({
    required String phone,
    required String takeType,
  }) async {
    print('🔄 OtpCubit: بدء إرسال OTP للرقم: $phone');
    emit(OtpGenerateLoading());

    final result = await _otpRepository.generateOtp(
      phone: phone,
      takeType: takeType,
    );

    result.fold(
      (failure) {
        print('❌ OtpCubit: فشل إرسال OTP: ${failure.message}');
        emit(OtpGenerateError(failure.message));
      },
      (response) {
        print('✅ OtpCubit: تم إرسال OTP بنجاح');
        emit(OtpGenerateSuccess(response, phone));
      },
    );
  }

  Future<void> verifyOtp({
    required String phone,
    required String otp,
    required String takeType,
  }) async {
    emit(OtpVerifyLoading());

    final result = await _otpRepository.verifyOtp(
      phone: phone,
      otp: otp,
      takeType: takeType,
    );

    result.fold(
      (failure) => emit(OtpVerifyError(failure.message)),
      (response) => emit(OtpVerifySuccess(response)),
    );
  }

  void resetToInitial() {
    emit(OtpInitial());
  }

  void goToOtpInput(String phone) {
    emit(OtpInput(phone));
  }
}
