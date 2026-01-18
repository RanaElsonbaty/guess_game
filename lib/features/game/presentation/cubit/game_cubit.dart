import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/game/data/models/assign_winner_request.dart';
import 'package:guess_game/features/game/data/models/assign_winner_response.dart';
import 'package:guess_game/features/game/data/models/game_statistics_response.dart';
import 'package:guess_game/features/game/data/models/game_start_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_request.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/models/update_score_request.dart';
import 'package:guess_game/features/game/data/models/update_score_response.dart';
import 'package:guess_game/features/game/data/repositories/game_repository.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final GameRepository _gameRepository;

  // حفظ response للاستخدام في صفحات أخرى
  GameStartResponse? gameStartResponse;
  UpdatePointPlanResponse? updatePointPlanResponse;
  UpdateScoreResponse? updateScoreResponse;
  GameStatisticsResponse? gameStatisticsResponse;

  GameCubit(this._gameRepository) : super(GameInitial());

  Future<void> startGame(GameStartRequest request) async {
    emit(GameStarting());

    final result = await _gameRepository.startGame(request);

    result.fold(
      (failure) {
        emit(GameStartError(failure.message));
      },
      (response) {
        // حفظ response للاستخدام في صفحات أخرى
        gameStartResponse = response;
        emit(GameStarted(response));
      },
    );
  }

  Future<void> updatePointPlan(UpdatePointPlanRequest request) async {
    emit(PointPlanUpdating());

    final result = await _gameRepository.updatePointPlan(request);

    result.fold(
      (failure) {
        emit(PointPlanUpdateError(failure.message));
      },
      (response) {
        // حفظ response للاستخدام في صفحات أخرى
        updatePointPlanResponse = response;
        emit(PointPlanUpdated(response));
      },
    );
  }

  Future<UpdateScoreResponse?> updateScore(UpdateScoreRequest request) async {
    emit(ScoreUpdating());

    final result = await _gameRepository.updateScore(request);
    return result.fold(
      (failure) {
        emit(ScoreUpdateError(failure.message));
        return null;
      },
      (response) {
        updateScoreResponse = response;
        emit(ScoreUpdated(response));
        return response;
      },
    );
  }

  Future<AssignWinnerResponse?> assignWinner(AssignWinnerRequest request) async {
    if (kDebugMode) {
      print('🎯 GameCubit: assignWinner called');
      print('🎯 GameCubit: request = ${request.toJson()}');
    }

    emit(WinnerAssigning());

    final result = await _gameRepository.assignWinner(request);
    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('🎯 GameCubit: assignWinner failed: ${failure.message}');
        }
        emit(WinnerAssignError(failure.message));
        return null;
      },
      (response) {
        if (kDebugMode) {
          print('🎯 GameCubit: assignWinner success');
        }
        emit(WinnerAssigned(response));
        return response;
      },
    );
  }

  Future<GameStatisticsResponse?> getGameStatistics(int gameId) async {
    emit(GameStatisticsLoading());
    final result = await _gameRepository.gameStatistics(gameId);
    return result.fold(
      (failure) {
        emit(GameStatisticsError(failure.message));
        return null;
      },
      (response) {
        gameStatisticsResponse = response;
        emit(GameStatisticsLoaded(response));
        return response;
      },
    );
  }
}
