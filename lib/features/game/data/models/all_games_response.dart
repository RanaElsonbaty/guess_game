class AllGamesResponse {
  final bool success;
  final String message;
  final int code;
  final List<GameItem> data;
  final Map<String, dynamic>? metaData;

  AllGamesResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    this.metaData,
  });

  factory AllGamesResponse.fromJson(Map<String, dynamic> json) {
    return AllGamesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => GameItem.fromJson(item))
          .toList() ?? [],
      metaData: json['meta_data'] as Map<String, dynamic>?,
    );
  }
}

class GameItem {
  final int id;
  final String name;
  final String status;
  final List<RoundData> rounds;
  final List<TeamInfo> teams;

  GameItem({
    required this.id,
    required this.name,
    required this.status,
    required this.rounds,
    required this.teams,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      rounds: (json['rounds'] as List<dynamic>?)
          ?.map((round) => RoundData.fromJson(round))
          .toList() ?? [],
      teams: (json['teams'] as List<dynamic>?)
          ?.map((team) => TeamInfo.fromJson(team))
          .toList() ?? [],
    );
  }
}

class PackageData {
  final int id;
  final String name;
  final String description;
  final String price;
  final int points;
  final int limit;
  final int subscriptionId;
  final String subscriptionStatus;
  final List<RoundData> rounds;

  PackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.points,
    required this.limit,
    required this.subscriptionId,
    required this.subscriptionStatus,
    required this.rounds,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    return PackageData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      points: json['points'] ?? 0,
      limit: json['limit'] ?? 0,
      subscriptionId: json['subscription_id'] ?? 0,
      subscriptionStatus: json['subscription_status'] ?? '',
      rounds: (json['rounds'] as List<dynamic>?)
          ?.map((round) => RoundData.fromJson(round))
          .toList() ?? [],
    );
  }
}

class RoundData {
  final int id;
  final int roundNumber;
  final List<RoundDataItem> roundData;

  RoundData({
    required this.id,
    required this.roundNumber,
    required this.roundData,
  });

  factory RoundData.fromJson(Map<String, dynamic> json) {
    return RoundData(
      id: json['id'] ?? 0,
      roundNumber: json['round_number'] ?? 0,
      roundData: (json['round_data'] as List<dynamic>?)
          ?.map((data) => RoundDataItem.fromJson(data))
          .toList() ?? [],
    );
  }
}

class RoundDataItem {
  final int id;
  final int roundId;
  final int teamId;
  final int categoryId;
  final CategoryInfo? category;
  final TeamInfo? team;
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

  RoundDataItem({
    required this.id,
    required this.roundId,
    required this.teamId,
    required this.categoryId,
    this.category,
    this.team,
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

  factory RoundDataItem.fromJson(Map<String, dynamic> json) {
    return RoundDataItem(
      id: json['id'] ?? 0,
      roundId: json['round_id'] ?? 0,
      teamId: json['team_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      category: json['category'] != null ? CategoryInfo.fromJson(json['category']) : null,
      team: json['team'] != null ? TeamInfo.fromJson(json['team']) : null,
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

class CategoryInfo {
  final int id;
  final String name;
  final String image;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class TeamInfo {
  final int id;
  final String name;
  final int totalPoints;
  final int teamNumber;
  final bool isWinner;
  final List<RoundDataItem> roundData;

  TeamInfo({
    required this.id,
    required this.name,
    required this.totalPoints,
    required this.teamNumber,
    required this.isWinner,
    required this.roundData,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      teamNumber: json['team_number'] ?? 0,
      isWinner: json['is_winner'] ?? false,
      roundData: (json['round_data'] as List<dynamic>?)
          ?.map((data) => RoundDataItem.fromJson(data))
          .toList() ?? [],
    );
  }
}