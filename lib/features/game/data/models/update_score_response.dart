class UpdateScoreResponse {
  final bool success;
  final String message;
  final int code;
  final List<UpdateScoreData> data;
  final List<dynamic> metaData;

  UpdateScoreResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory UpdateScoreResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<UpdateScoreData> parsedData;
    if (rawData is List) {
      parsedData = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => UpdateScoreData.fromJson(e))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      parsedData = [UpdateScoreData.fromJson(rawData)];
    } else {
      parsedData = const <UpdateScoreData>[];
    }
    return UpdateScoreResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: parsedData,
      metaData: json['meta_data'] ?? [],
    );
  }
}

class UpdateScoreData {
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

  UpdateScoreData({
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

  factory UpdateScoreData.fromJson(Map<String, dynamic> json) {
    return UpdateScoreData(
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
}


