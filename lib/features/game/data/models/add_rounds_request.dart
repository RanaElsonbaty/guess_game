class AddRoundsRequest {
  final int gameId;
  final List<AddRoundsTeamPayload> rounds;

  const AddRoundsRequest({
    required this.gameId,
    required this.rounds,
  });

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'rounds': rounds.map((e) => e.toJson()).toList(),
    };
  }
}

class AddRoundsTeamPayload {
  final int teamId;
  final List<int> categoriesIds;

  const AddRoundsTeamPayload({
    required this.teamId,
    required this.categoriesIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'categories_ids': categoriesIds,
    };
  }
}


