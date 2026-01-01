import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/auth/login/data/models/login_email_response.dart';

class LoginEmailRepository extends BaseRepository {
  final ApiService _apiService;

  LoginEmailRepository(this._apiService);

  Future<Either<ApiFailure, LoginEmailResponse>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return guardFuture(() async {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'login_type': 'email',
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

          return LoginEmailResponse.fromJson(data);
        },
      );
    });
  }
}




