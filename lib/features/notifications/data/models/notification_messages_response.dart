/// Response model for notification messages API
class NotificationMessagesResponse {
  final bool success;
  final String message;
  final int code;
  final NotificationMessagesData data;
  final List<dynamic> metaData;

  NotificationMessagesResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory NotificationMessagesResponse.fromJson(Map<String, dynamic> json) {
    return NotificationMessagesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      data: NotificationMessagesData.fromJson(json['data'] as Map<String, dynamic>),
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

/// Data model for notification messages
class NotificationMessagesData {
  final String notSubscribedMessage;
  final List<String> gameTerms;

  NotificationMessagesData({
    required this.notSubscribedMessage,
    required this.gameTerms,
  });

  factory NotificationMessagesData.fromJson(Map<String, dynamic> json) {
    return NotificationMessagesData(
      notSubscribedMessage: json['not_subscribed_message'] as String? ?? '',
      gameTerms: (json['game_terms'] as List<dynamic>?)
          ?.map((term) => term as String)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'not_subscribed_message': notSubscribedMessage,
      'game_terms': gameTerms,
    };
  }
}
