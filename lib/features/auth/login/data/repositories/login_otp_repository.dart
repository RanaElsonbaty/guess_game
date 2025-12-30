import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/auth/login/data/models/login_otp_response.dart';

class LoginOtpRepository extends BaseRepository {
  final ApiService _apiService;

  LoginOtpRepository(this._apiService);

  Future<Either<ApiFailure, LoginOtpResponse>> loginWithOtp({
    required String phone,
    required String otp,
    required String loginType,
  }) async {
    return guardFuture(() async {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'phone': phone,
          'otp': otp,
          'login_type': loginType,
        },
      );

      return response.fold(
        (failure) => throw failure,
        (success) {
          final data = success.data;
          if (data == null) {
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            throw ApiFailure('Invalid response format');
          }

          return LoginOtpResponse.fromJson(data);
        },
      );
    });
  }

  Future<Either<ApiFailure, LoginOtpResponse>> loginWithEmailOtp({
    required String email,
    required String otp,
    required String loginType,
  }) async {
    return guardFuture(() async {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'otp': otp,
          'login_type': loginType,
        },
      );

      return response.fold(
        (failure) => throw failure,
        (success) {
          final data = success.data;
          if (data == null) {
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            throw ApiFailure('Invalid response format');
          }

          return LoginOtpResponse.fromJson(data);
        },
      );
    });
  }
}

