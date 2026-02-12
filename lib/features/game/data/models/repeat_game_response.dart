import 'package:guess_game/features/game/data/models/all_games_response.dart';

class RepeatGameResponse {
  final bool success;
  final String message;
  final int code;
  final GameData data;
  final List<dynamic> metaData;

  RepeatGameResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory RepeatGameResponse.fromJson(Map<String, dynamic> json) {
    return RepeatGameResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: GameData.fromJson(json['data']),
      metaData: json['meta_data'] ?? [],
    );
  }
}

class GameData {
  final int id;
  final String name;
  final String status;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final List<TeamInfo> teams;
  final List<RoundData> rounds;

  GameData({
    required this.id,
    required this.name,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.teams,
    required this.rounds,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      teams: (json['teams'] as List<dynamic>?)
          ?.map((team) => TeamInfo.fromJson(team))
          .toList() ?? [],
      rounds: (json['rounds'] as List<dynamic>?)
          ?.map((round) => RoundData.fromJson(round))
          .toList() ?? [],
    );
  }
}
