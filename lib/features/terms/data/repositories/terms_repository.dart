import 'package:dartz/dartz.dart';
import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/terms/data/models/game_terms_response.dart';

/// Abstract repository interface for terms
abstract class TermsRepository {
  /// Get game terms from API
  Future<Either<ApiFailure, GameTermsResponse>> getGameTerms();
}

/// Implementation of TermsRepository using ApiService
class TermsRepositoryImpl extends BaseRepository implements TermsRepository {
  final ApiService _apiService;

  TermsRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiFailure, GameTermsResponse>> getGameTerms() async {
    return guardFuture(() async {
      final response = await _apiService.get(ApiConstants.gameTerms);

      return response.fold(
        (failure) => throw failure,
        (success) {
          final data = success.data;
          if (data == null) {
            throw ApiFailure('No data received from server');
          }

          // Check if response has the expected structure
          if (data is! Map<String, dynamic>) {
            throw ApiFailure('Invalid response format');
          }

          // Check for success status
          final isSuccess = data['success'] as bool?;
          if (isSuccess != true) {
            final message = data['message'] as String? ?? 'Request failed';
            throw ApiFailure(message);
          }

          // Parse the response
          final gameTermsResponse = GameTermsResponse.fromJson(data);
          return gameTermsResponse;
        },
      );
    });
  }
}






