class RepeatGameRequest {
  final int gameId;
  final List<RepeatGameTeam> teams;

  RepeatGameRequest({
    required this.gameId,
    required this.teams,
  });

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'teams': teams.map((team) => team.toJson()).toList(),
    };
  }
}

class RepeatGameTeam {
  final String name;
  final int teamNumber;

  RepeatGameTeam({
    required this.name,
    required this.teamNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'team_number': teamNumber,
    };
  }
}
