class GameStartResponse {
  final bool success;
  final String message;
  final int code;
  final GameData data;
  final List<dynamic> metaData;

  GameStartResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory GameStartResponse.fromJson(Map<String, dynamic> json) {
    return GameStartResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: GameData.fromJson(json['data'] ?? {}),
      metaData: json['meta_data'] ?? [],
    );
  }
}

class GameData {
  final String name;
  final String status;
  final int userId;
  final String updatedAt;
  final String createdAt;
  final int id;
  final List<GameTeamData> teams;
  final List<GameRound> rounds;

  GameData({
    required this.name,
    required this.status,
    required this.userId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.teams,
    required this.rounds,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      userId: json['user_id'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
      teams: (json['teams'] as List<dynamic>?)
          ?.map((team) => GameTeamData.fromJson(team))
          .toList() ?? [],
      rounds: (json['rounds'] as List<dynamic>?)
          ?.map((round) => GameRound.fromJson(round))
          .toList() ?? [],
    );
  }
}

class GameTeamData {
  final int id;
  final int gameId;
  final int teamNumber;
  final String name;
  final String? image;
  final bool isWinner;
  final String createdAt;
  final String updatedAt;
  final int totalPoints;
  final List<RoundData> roundData;

  GameTeamData({
    required this.id,
    required this.gameId,
    required this.teamNumber,
    required this.name,
    this.image,
    required this.isWinner,
    required this.createdAt,
    required this.updatedAt,
    required this.totalPoints,
    required this.roundData,
  });

  factory GameTeamData.fromJson(Map<String, dynamic> json) {
    return GameTeamData(
      id: json['id'] ?? 0,
      gameId: json['game_id'] ?? 0,
      teamNumber: json['team_number'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      isWinner: json['is_winner'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      roundData: (json['round_data'] as List<dynamic>?)
          ?.map((roundData) => RoundData.fromJson(roundData))
          .toList() ?? [],
    );
  }
}

class RoundData {
  final int id;
  final int roundId;
  final int teamId;
  final int categoryId;
  final dynamic pointPlan;
  final String status;
  final int pointEarned;
  final String? qrCode;
  final int questionNumber;
  final int answerNumber;
  final String createdAt;
  final String updatedAt;
  final int maxAnswers;
  final int maxQuestions;

  RoundData({
    required this.id,
    required this.roundId,
    required this.teamId,
    required this.categoryId,
    this.pointPlan,
    required this.status,
    required this.pointEarned,
    this.qrCode,
    required this.questionNumber,
    required this.answerNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.maxAnswers,
    required this.maxQuestions,
  });

  factory RoundData.fromJson(Map<String, dynamic> json) {
    return RoundData(
      id: json['id'] ?? 0,
      roundId: json['round_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      pointPlan: json['point_plan'],
      status: json['status'] ?? '',
      pointEarned: json['point_earned'] ?? 0,
      qrCode: json['qr_code'],
      questionNumber: json['question_number'] ?? 0,
      answerNumber: json['answer_number'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      maxAnswers: json['max_answers'] ?? 0,
      maxQuestions: json['max_questions'] ?? 0,
    );
  }
}

class GameRound {
  final int id;
  final int gameId;
  final int subscriptionId;
  final int roundNumber;
  final String createdAt;
  final String updatedAt;
  final List<RoundData> roundData;

  GameRound({
    required this.id,
    required this.gameId,
    required this.subscriptionId,
    required this.roundNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.roundData,
  });

  factory GameRound.fromJson(Map<String, dynamic> json) {
    return GameRound(
      id: json['id'] ?? 0,
      gameId: json['game_id'] ?? 0,
      subscriptionId: json['subscription_id'] ?? 0,
      roundNumber: json['round_number'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      roundData: (json['round_data'] as List<dynamic>?)
          ?.map((roundData) => RoundData.fromJson(roundData))
          .toList() ?? [],
    );
  }
}