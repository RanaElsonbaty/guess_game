class OtpVerifyResponse {
  final bool success;
  final String message;
  final int code;
  final dynamic data;
  final List metaData;

  OtpVerifyResponse({
    required this.success,
    required this.message,
    required this.code,
    this.data,
    required this.metaData,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: json['data'],
      metaData: json['meta_data'] as List,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'code': code,
      'data': data,
      'meta_data': metaData,
    };
  }
}




