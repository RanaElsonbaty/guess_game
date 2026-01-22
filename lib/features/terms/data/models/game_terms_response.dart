/// Response model for game terms API
class GameTermsResponse {
  final bool success;
  final String message;
  final int code;
  final GameTermsData data;
  final List<dynamic> metaData;

  GameTermsResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory GameTermsResponse.fromJson(Map<String, dynamic> json) {
    return GameTermsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      data: GameTermsData.fromJson(json['data'] as Map<String, dynamic>),
      metaData: json['meta_data'] as List<dynamic>? ?? [],
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

/// Data model for game terms
class GameTermsData {
  final List<String> gameTerms;

  GameTermsData({
    required this.gameTerms,
  });

  factory GameTermsData.fromJson(Map<String, dynamic> json) {
    return GameTermsData(
      gameTerms: (json['game_terms'] as List<dynamic>?)
          ?.map((term) => term as String)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_terms': gameTerms,
    };
  }
}






