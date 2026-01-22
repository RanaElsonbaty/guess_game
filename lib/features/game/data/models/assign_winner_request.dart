class AssignWinnerRequest {
  final int gameId;
  final int roundId;
  final int teamId;

  AssignWinnerRequest({
    required this.gameId,
    required this.roundId,
    required this.teamId,
  });

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'round_id': roundId,
      'team_id': teamId,
    };
  }
}







