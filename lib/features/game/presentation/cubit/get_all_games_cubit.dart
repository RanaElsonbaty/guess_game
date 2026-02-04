import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/game/data/models/all_games_response.dart';
import 'package:guess_game/features/game/data/repositories/game_repository.dart';

// States
abstract class GetAllGamesState {}

class GetAllGamesInitial extends GetAllGamesState {}

class GetAllGamesLoading extends GetAllGamesState {}

class GetAllGamesLoaded extends GetAllGamesState {
  final AllGamesResponse response;

  GetAllGamesLoaded(this.response);
}

class GetAllGamesError extends GetAllGamesState {
  final String message;

  GetAllGamesError(this.message);
}

// Cubit
class GetAllGamesCubit extends Cubit<GetAllGamesState> {
  final GameRepository _gameRepository;

  GetAllGamesCubit(this._gameRepository) : super(GetAllGamesInitial());

  Future<void> getAllGames() async {
    emit(GetAllGamesLoading());

    final result = await _gameRepository.getAllGames();

    result.fold(
      (failure) => emit(GetAllGamesError(failure.message)),
      (response) => emit(GetAllGamesLoaded(response)),
    );
  }
}