import 'package:dartz/dartz.dart';
import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/features/game/data/models/assign_winner_request.dart';
import 'package:guess_game/features/game/data/models/assign_winner_response.dart';
import 'package:guess_game/features/game/data/models/game_statistics_response.dart';
import 'package:guess_game/features/game/data/models/game_start_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_request.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/models/update_score_request.dart';
import 'package:guess_game/features/game/data/models/update_score_response.dart';

abstract class GameRepository {
  Future<Either<ApiFailure, GameStartResponse>> startGame(GameStartRequest request);
  Future<Either<ApiFailure, UpdatePointPlanResponse>> updatePointPlan(UpdatePointPlanRequest request);
  Future<Either<ApiFailure, UpdateScoreResponse>> updateScore(UpdateScoreRequest request);
  Future<Either<ApiFailure, AssignWinnerResponse>> assignWinner(AssignWinnerRequest request);
  Future<Either<ApiFailure, GameStatisticsResponse>> gameStatistics(int gameId);
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

  @override
  Future<Either<ApiFailure, UpdatePointPlanResponse>> updatePointPlan(UpdatePointPlanRequest request) async {
    try {
      final response = await _apiService.patch(ApiConstants.gamesRoundDataUpdatePointPlan, data: request.toJson());

      return response.fold(
        (failure) => Left(failure),
        (success) {
          if (success.statusCode == 200) {
            final updateResponse = UpdatePointPlanResponse.fromJson(success.data);
            return Right(updateResponse);
          } else {
            return Left(ApiFailure('فشل في تحديث point_plan'));
          }
        },
      );
    } catch (e) {
      return Left(ApiFailure('حدث خطأ أثناء تحديث point_plan: $e'));
    }
  }

  @override
  Future<Either<ApiFailure, UpdateScoreResponse>> updateScore(UpdateScoreRequest request) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.gamesRoundDataUpdateScore,
        data: request.toJson(),
      );

      return response.fold(
        (failure) => Left(failure),
        (success) {
          if (success.statusCode == 200) {
            final updateResponse = UpdateScoreResponse.fromJson(success.data);
            return Right(updateResponse);
          } else {
            return Left(ApiFailure('فشل في تحديث score'));
          }
        },
      );
    } catch (e) {
      return Left(ApiFailure('حدث خطأ أثناء تحديث score: $e'));
    }
  }

  @override
  Future<Either<ApiFailure, AssignWinnerResponse>> assignWinner(AssignWinnerRequest request) async {
    try {
      final response = await _apiService.put(
        ApiConstants.gamesRoundAssignWinner,
        data: request.toJson(),
      );

      return response.fold(
        (failure) => Left(failure),
        (success) {
          if (success.statusCode == 200) {
            final assignResponse = AssignWinnerResponse.fromJson(success.data);
            return Right(assignResponse);
          } else {
            return Left(ApiFailure('فشل في تعيين الفائز'));
          }
        },
      );
    } catch (e) {
      return Left(ApiFailure('حدث خطأ أثناء تعيين الفائز: $e'));
    }
  }

  @override
  Future<Either<ApiFailure, GameStatisticsResponse>> gameStatistics(int gameId) async {
    try {
      final response = await _apiService.get(ApiConstants.gamesStatistics(gameId));

      return response.fold(
        (failure) => Left(failure),
        (success) {
          if (success.statusCode == 200) {
            final statsResponse =
                GameStatisticsResponse.fromJson(success.data as Map<String, dynamic>);
            return Right(statsResponse);
          } else {
            return Left(ApiFailure('فشل في جلب إحصائيات اللعبة'));
          }
        },
      );
    } catch (e) {
      return Left(ApiFailure('حدث خطأ أثناء جلب إحصائيات اللعبة: $e'));
    }
  }
}