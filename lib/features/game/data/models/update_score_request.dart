class UpdateScoreRequest {
  final int gameId;
  final List<RoundScoreUpdate> roundsData;

  UpdateScoreRequest({
    required this.gameId,
    required this.roundsData,
  });

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'rounds_data': roundsData.map((r) => r.toJson()).toList(),
    };
  }
}

class RoundScoreUpdate {
  final int roundDataId;
  final int questionsCount;
  final int answersCount;

  RoundScoreUpdate({
    required this.roundDataId,
    required this.questionsCount,
    required this.answersCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'round_data_id': roundDataId,
      'questions_count': questionsCount,
      'answers_count': answersCount,
    };
  }
}


