class UpdatePointPlanResponse {
  final bool success;
  final String message;
  final int code;
  final UpdatePointPlanData data;
  final List<dynamic> metaData;

  UpdatePointPlanResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory UpdatePointPlanResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePointPlanResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: UpdatePointPlanData.fromJson(json['data'] ?? {}),
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

class UpdatePointPlanData {
  final int id;
  final int gameId;
  final dynamic roundId;
  final List<UpdatedRoundData> roundData;

  UpdatePointPlanData({
    required this.id,
    required this.gameId,
    this.roundId,
    required this.roundData,
  });

  factory UpdatePointPlanData.fromJson(Map<String, dynamic> json) {
    return UpdatePointPlanData(
      id: json['id'] ?? 0,
      gameId: json['game_id'] ?? 0,
      roundId: json['round_id'],
      roundData: (json['round_data'] as List<dynamic>?)
          ?.map((roundData) => UpdatedRoundData.fromJson(roundData))
          .toList() ?? [],
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

class UpdatedRoundData {
  final int id;
  final int roundId;
  final int teamId;
  final int categoryId;
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

  UpdatedRoundData({
    required this.id,
    required this.roundId,
    required this.teamId,
    required this.categoryId,
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

  factory UpdatedRoundData.fromJson(Map<String, dynamic> json) {
    return UpdatedRoundData(
      id: json['id'] ?? 0,
      roundId: json['round_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
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



