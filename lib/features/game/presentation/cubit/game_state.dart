part of 'game_cubit.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameStarting extends GameState {}

class GameStarted extends GameState {
  final GameStartResponse response;

  GameStarted(this.response);
}

class GameStartError extends GameState {
  final String message;

  GameStartError(this.message);
}

class PointPlanUpdating extends GameState {}

class PointPlanUpdated extends GameState {
  final UpdatePointPlanResponse response;

  PointPlanUpdated(this.response);
}

class PointPlanUpdateError extends GameState {
  final String message;

  PointPlanUpdateError(this.message);
}

class ScoreUpdating extends GameState {}

class ScoreUpdated extends GameState {
  final UpdateScoreResponse response;

  ScoreUpdated(this.response);
}

class ScoreUpdateError extends GameState {
  final String message;

  ScoreUpdateError(this.message);
}

class WinnerAssigning extends GameState {}

class WinnerAssigned extends GameState {
  final AssignWinnerResponse response;

  WinnerAssigned(this.response);
}

class WinnerAssignError extends GameState {
  final String message;

  WinnerAssignError(this.message);
}

class GameStatisticsLoading extends GameState {}

class GameStatisticsLoaded extends GameState {
  final GameStatisticsResponse response;

  GameStatisticsLoaded(this.response);
}

class GameStatisticsError extends GameState {
  final String message;

  GameStatisticsError(this.message);
}

class GameEnding extends GameState {}

class GameEnded extends GameState {
  final GameStartResponse response;

  GameEnded(this.response);
}

class GameEndError extends GameState {
  final String message;

  GameEndError(this.message);
}


