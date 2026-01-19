import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/features/game/data/models/add_rounds_request.dart';
import 'package:guess_game/features/game/data/models/game_start_response.dart';
import 'package:guess_game/features/game/data/repositories/game_repository.dart';

sealed class AddOneRoundState {}

final class AddOneRoundInitial extends AddOneRoundState {}

final class AddOneRoundLoading extends AddOneRoundState {}

final class AddOneRoundSuccess extends AddOneRoundState {
  final GameStartResponse response;
  AddOneRoundSuccess(this.response);
}

final class AddOneRoundError extends AddOneRoundState {
  final String message;
  AddOneRoundError(this.message);
}

class AddOneRoundCubit extends Cubit<AddOneRoundState> {
  final GameRepository _gameRepository;

  AddOneRoundCubit(this._gameRepository) : super(AddOneRoundInitial());

  Future<void> addRounds({
    required int gameId,
    required int team1Id,
    required int team2Id,
    required int team1CategoryId,
    required int team2CategoryId,
  }) async {
    emit(AddOneRoundLoading());

    final request = AddRoundsRequest(
      gameId: gameId,
      rounds: [
        AddRoundsTeamPayload(teamId: team1Id, categoriesIds: [team1CategoryId]),
        AddRoundsTeamPayload(teamId: team2Id, categoriesIds: [team2CategoryId]),
      ],
    );

    final result = await _gameRepository.addRounds(request);
    await result.fold(
      (failure) async {
        emit(AddOneRoundError(failure.message));
      },
      (response) async {
        // Update the in-session game response and jump to the newly added round (last round).
        await GlobalStorage.updateGameStartResponse(response);
        GlobalStorage.lastGameStartResponse = response;
        GlobalStorage.currentRoundIndex = (response.data.rounds.isNotEmpty) ? response.data.rounds.length - 1 : 0;
        emit(AddOneRoundSuccess(response));
      },
    );
  }
}


