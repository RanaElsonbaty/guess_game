import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/logout_response_model.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

/// Abstract repository interface for authentication
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<ApiFailure, LoginResponseModel>> login(String email, String password);

  /// Get user profile
  Future<Either<ApiFailure, UserModel>> getProfile();

  /// Logout (invalidate token)
  Future<Either<ApiFailure, LogoutResponseModel>> logout();
}

/// Implementation of AuthRepository using ApiService
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiFailure, LoginResponseModel>> login(String email, String password) async {
    return guardFuture(() async {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

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

          final isSuccess = data['success'] as bool?;
          if (isSuccess != true) {
            final message = data['message'] as String? ?? 'Login failed';
            throw ApiFailure(message);
          }

          final userData = data['data'];
          if (userData == null) {
            throw ApiFailure('No user data found');
          }

          if (userData is! Map<String, dynamic>) {
            throw ApiFailure('Invalid user data format');
          }

          return LoginResponseModel.fromJson(userData);
        },
      );
    });
  }

  @override
  Future<Either<ApiFailure, UserModel>> getProfile() async {
    return guardFuture(() async {
      final response = await _apiService.get('/auth/profile');

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

          final isSuccess = data['success'] as bool?;
          if (isSuccess != true) {
            final message = data['message'] as String? ?? 'Failed to get profile';
            throw ApiFailure(message);
          }

          final userData = data['data'];
          if (userData == null) {
            throw ApiFailure('No user data found');
          }

          if (userData is! Map<String, dynamic>) {
            throw ApiFailure('Invalid user data format');
          }

          return UserModel.fromJson(userData);
        },
      );
    });
  }

  @override
  Future<Either<ApiFailure, LogoutResponseModel>> logout() async {
    return guardFuture(() async {
      final response = await _apiService.post('/auth/logout');

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

          final isSuccess = data['success'] as bool?;
          if (isSuccess != true) {
            final message = data['message'] as String? ?? 'Logout failed';
            throw ApiFailure(message);
          }

          return LogoutResponseModel.fromJson(data);
        },
      );
    });
  }
}





