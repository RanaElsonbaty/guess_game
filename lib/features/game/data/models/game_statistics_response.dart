class GameStatisticsResponse {
  final bool success;
  final String message;
  final int code;
  final GameStatisticsData data;
  final List<dynamic> metaData;

  GameStatisticsResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory GameStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return GameStatisticsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: GameStatisticsData.fromJson(json['data'] ?? const {}),
      metaData: (json['meta_data'] as List?)?.toList() ?? const [],
    );
  }
}

class GameStatisticsData {
  final GameInfo game;
  final GameStatisticsSummary statistics;
  final List<GameStatisticsTeam> teams;
  final List<GameStatisticsRound> rounds;

  GameStatisticsData({
    required this.game,
    required this.statistics,
    required this.teams,
    required this.rounds,
  });

  factory GameStatisticsData.fromJson(Map<String, dynamic> json) {
    return GameStatisticsData(
      game: GameInfo.fromJson(json['game'] ?? const {}),
      statistics: GameStatisticsSummary.fromJson(json['statistics'] ?? const {}),
      teams: (json['teams'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(GameStatisticsTeam.fromJson)
              .toList() ??
          const [],
      rounds: (json['rounds'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(GameStatisticsRound.fromJson)
              .toList() ??
          const [],
    );
  }
}

class GameInfo {
  final int id;
  final String name;
  final String status;
  final String createdAt;
  final String updatedAt;

  GameInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class GameStatisticsSummary {
  final int totalRounds;
  final int totalPoints;
  final int wins;
  final int losses;
  final int draws;

  GameStatisticsSummary({
    required this.totalRounds,
    required this.totalPoints,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  factory GameStatisticsSummary.fromJson(Map<String, dynamic> json) {
    return GameStatisticsSummary(
      totalRounds: json['total_rounds'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
    );
  }
}

class GameStatisticsTeam {
  final int teamId;
  final int teamNumber;
  final String name;
  final dynamic image;
  final bool isWinner;
  final int totalPoints;
  final int wins;
  final int losses;
  final int draws;

  GameStatisticsTeam({
    required this.teamId,
    required this.teamNumber,
    required this.name,
    required this.image,
    required this.isWinner,
    required this.totalPoints,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  factory GameStatisticsTeam.fromJson(Map<String, dynamic> json) {
    return GameStatisticsTeam(
      teamId: json['team_id'] ?? 0,
      teamNumber: json['team_number'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      isWinner: json['is_winner'] ?? false,
      totalPoints: json['total_points'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
    );
  }
}

class GameStatisticsRound {
  final int roundId;
  final int roundNumber;
  final List<GameStatisticsRoundTeamData> teamsData;

  GameStatisticsRound({
    required this.roundId,
    required this.roundNumber,
    required this.teamsData,
  });

  factory GameStatisticsRound.fromJson(Map<String, dynamic> json) {
    return GameStatisticsRound(
      roundId: json['round_id'] ?? 0,
      roundNumber: json['round_number'] ?? 0,
      teamsData: (json['teams_data'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(GameStatisticsRoundTeamData.fromJson)
              .toList() ??
          const [],
    );
  }
}

class GameStatisticsRoundTeamData {
  final int roundDataId;
  final int teamId;
  final String teamName;
  final int teamNumber;
  final int categoryId;
  final String categoryName;
  final dynamic pointPlan;
  final int pointEarned;
  final String status;
  final int questionNumber;
  final dynamic qrCode;
  final int answerNumber;
  final int maxQuestions;
  final int maxAnswers;

  GameStatisticsRoundTeamData({
    required this.roundDataId,
    required this.teamId,
    required this.teamName,
    required this.teamNumber,
    required this.categoryId,
    required this.categoryName,
    required this.pointPlan,
    required this.pointEarned,
    required this.status,
    required this.questionNumber,
    required this.qrCode,
    required this.answerNumber,
    required this.maxQuestions,
    required this.maxAnswers,
  });

  factory GameStatisticsRoundTeamData.fromJson(Map<String, dynamic> json) {
    return GameStatisticsRoundTeamData(
      roundDataId: json['round_data_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      teamName: json['team_name'] ?? '',
      teamNumber: json['team_number'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      pointPlan: json['point_plan'],
      pointEarned: json['point_earned'] ?? 0,
      status: json['status'] ?? '',
      questionNumber: json['question_number'] ?? 0,
      qrCode: json['qr_code'],
      answerNumber: json['answer_number'] ?? 0,
      maxQuestions: json['max_questions'] ?? 0,
      maxAnswers: json['max_answers'] ?? 0,
    );
  }
}


