import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/auth/register/data/models/register_response.dart';

class RegisterRepository extends BaseRepository {
  final ApiService _apiService;

  RegisterRepository(this._apiService);

  Future<Either<ApiFailure, RegisterResponse>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return guardFuture(() async {
      final response = await _apiService.post(
        '/auth/${ApiConstants.REGISTER}',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
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

          return RegisterResponse.fromJson(data);
        },
      );
    });
  }
}
