class GameStartRequest {
  final List<GameTeam> teams;

  GameStartRequest({required this.teams});

  Map<String, dynamic> toJson() {
    return {
      'teams': teams.map((team) => team.toJson()).toList(),
    };
  }
}

class GameTeam {
  final int teamNumber;
  final String name;
  final List<int> categoriesIds;

  GameTeam({
    required this.teamNumber,
    required this.name,
    required this.categoriesIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_number': teamNumber,
      'name': name,
      'categories_ids': categoriesIds,
    };
  }
}


