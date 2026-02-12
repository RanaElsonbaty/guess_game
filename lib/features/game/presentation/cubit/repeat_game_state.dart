part of 'repeat_game_cubit.dart';

abstract class RepeatGameState {}

class RepeatGameInitial extends RepeatGameState {}

class RepeatGameLoading extends RepeatGameState {}

class RepeatGameSuccess extends RepeatGameState {
  final RepeatGameResponse response;

  RepeatGameSuccess(this.response);
}

class RepeatGameError extends RepeatGameState {
  final String message;

  RepeatGameError(this.message);
}
