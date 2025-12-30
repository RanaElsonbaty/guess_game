import 'package:dartz/dartz.dart';
import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/features/game/data/models/game_start_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';

abstract class GameRepository {
  Future<Either<ApiFailure, GameStartResponse>> startGame(GameStartRequest request);
}

class GameRepositoryImpl implements GameRepository {
  final ApiService _apiService;

  GameRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiFailure, GameStartResponse>> startGame(GameStartRequest request) async {
    try {
      final response = await _apiService.post(ApiConstants.gamesStart, data: request.toJson());

      return response.fold(
        (failure) => Left(failure),
        (success) {
          if (success.statusCode == 200) {
            final gameResponse = GameStartResponse.fromJson(success.data);
            return Right(gameResponse);
          } else {
            return Left(ApiFailure('فشل في بدء اللعبة'));
          }
        },
      );
    } catch (e) {
      return Left(ApiFailure('حدث خطأ أثناء بدء اللعبة: $e'));
    }
  }
}