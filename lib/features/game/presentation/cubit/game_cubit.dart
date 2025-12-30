import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/game/data/models/game_start_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_request.dart';
import 'package:guess_game/features/game/data/models/update_point_plan_response.dart';
import 'package:guess_game/features/game/data/repositories/game_repository.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final GameRepository _gameRepository;

  // حفظ response للاستخدام في صفحات أخرى
  UpdatePointPlanResponse? updatePointPlanResponse;

  GameCubit(this._gameRepository) : super(GameInitial());

  Future<void> startGame(GameStartRequest request) async {
    emit(GameStarting());

    final result = await _gameRepository.startGame(request);

    result.fold(
      (failure) {
        emit(GameStartError(failure.message));
      },
      (response) {
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
}
