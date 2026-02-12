import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/game/data/models/repeat_game_request.dart';
import 'package:guess_game/features/game/data/models/repeat_game_response.dart';
import 'package:guess_game/features/game/data/repositories/game_repository.dart';

part 'repeat_game_state.dart';

class RepeatGameCubit extends Cubit<RepeatGameState> {
  final GameRepository _gameRepository;

  RepeatGameCubit(this._gameRepository) : super(RepeatGameInitial());

  Future<void> repeatGame(RepeatGameRequest request) async {
    emit(RepeatGameLoading());

    final result = await _gameRepository.repeatGame(request);

    result.fold(
      (failure) => emit(RepeatGameError(failure.message)),
      (response) => emit(RepeatGameSuccess(response)),
    );
  }
}
