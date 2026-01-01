class OtpGenerateResponse {
  final bool success;
  final String message;
  final int code;
  final OtpGenerateData data;
  final List metaData;

  OtpGenerateResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory OtpGenerateResponse.fromJson(Map<String, dynamic> json) {
    return OtpGenerateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: OtpGenerateData.fromJson(json['data'] as Map<String, dynamic>),
      metaData: json['meta_data'] as List,
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

class OtpGenerateData {
  final String expiresAt;

  OtpGenerateData({
    required this.expiresAt,
  });

  factory OtpGenerateData.fromJson(Map<String, dynamic> json) {
    return OtpGenerateData(
      expiresAt: json['expires_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expires_at': expiresAt,
    };
  }
}




