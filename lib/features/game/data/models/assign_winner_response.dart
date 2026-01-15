class AssignWinnerResponse {
  final bool success;
  final String message;
  final int code;
  final AssignWinnerData data;
  final List<dynamic> metaData;

  AssignWinnerResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory AssignWinnerResponse.fromJson(Map<String, dynamic> json) {
    return AssignWinnerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: AssignWinnerData.fromJson(json['data'] ?? {}),
      metaData: json['meta_data'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'code': code,
      'data': data.toJson(),
      'meta_data': metaData,
    };
  }
}

class AssignWinnerData {
  final int id;
  final int gameId;
  final int roundId;
  final List<AssignWinnerRoundData> roundData;

  AssignWinnerData({
    required this.id,
    required this.gameId,
    required this.roundId,
    required this.roundData,
  });

  factory AssignWinnerData.fromJson(Map<String, dynamic> json) {
    final rawRoundData = json['round_data'];
    final List<AssignWinnerRoundData> parsedRoundData;
    if (rawRoundData is List) {
      parsedRoundData = rawRoundData
          .whereType<Map<String, dynamic>>()
          .map((e) => AssignWinnerRoundData.fromJson(e))
          .toList();
    } else {
      parsedRoundData = const <AssignWinnerRoundData>[];
    }

    return AssignWinnerData(
      id: json['id'] ?? 0,
      gameId: json['game_id'] ?? 0,
      roundId: json['round_id'] ?? 0,
      roundData: parsedRoundData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'round_id': roundId,
      'round_data': roundData.map((e) => e.toJson()).toList(),
    };
  }
}

class AssignWinnerRoundData {
  final int id;
  final int roundId;
  final int teamId;
  final int categoryId;
  final AssignWinnerTeam team;
  final int questionNumber;
  final int answerNumber;
  final int pointEarned;
  final int pointPlan;
  final String qrCode;
  final String imagePath;
  final bool canUpdateQuestions;
  final bool canUpdateAnswers;
  final int maxAnswers;
  final int maxQuestions;

  AssignWinnerRoundData({
    required this.id,
    required this.roundId,
    required this.teamId,
    required this.categoryId,
    required this.team,
    required this.questionNumber,
    required this.answerNumber,
    required this.pointEarned,
    required this.pointPlan,
    required this.qrCode,
    required this.imagePath,
    required this.canUpdateQuestions,
    required this.canUpdateAnswers,
    required this.maxAnswers,
    required this.maxQuestions,
  });

  factory AssignWinnerRoundData.fromJson(Map<String, dynamic> json) {
    return AssignWinnerRoundData(
      id: json['id'] ?? 0,
      roundId: json['round_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      team: AssignWinnerTeam.fromJson(json['team'] ?? {}),
      questionNumber: json['question_number'] ?? 0,
      answerNumber: json['answer_number'] ?? 0,
      pointEarned: json['point_earned'] ?? 0,
      pointPlan: json['point_plan'] ?? 0,
      qrCode: json['qr_code'] ?? '',
      imagePath: json['image_path'] ?? '',
      canUpdateQuestions: json['can_update_questions'] ?? false,
      canUpdateAnswers: json['can_update_answers'] ?? false,
      maxAnswers: json['max_answers'] ?? 0,
      maxQuestions: json['max_questions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'round_id': roundId,
      'team_id': teamId,
      'category_id': categoryId,
      'team': team.toJson(),
      'question_number': questionNumber,
      'answer_number': answerNumber,
      'point_earned': pointEarned,
      'point_plan': pointPlan,
      'qr_code': qrCode,
      'image_path': imagePath,
      'can_update_questions': canUpdateQuestions,
      'can_update_answers': canUpdateAnswers,
      'max_answers': maxAnswers,
      'max_questions': maxQuestions,
    };
  }
}

class AssignWinnerTeam {
  final int id;
  final String name;
  final int totalPoints;
  final int teamNumber;
  final bool isWinner;

  AssignWinnerTeam({
    required this.id,
    required this.name,
    required this.totalPoints,
    required this.teamNumber,
    required this.isWinner,
  });

  factory AssignWinnerTeam.fromJson(Map<String, dynamic> json) {
    return AssignWinnerTeam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      teamNumber: json['team_number'] ?? 0,
      isWinner: json['is_winner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_points': totalPoints,
      'team_number': teamNumber,
      'is_winner': isWinner,
    };
  }
}
