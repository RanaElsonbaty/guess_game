class LogoutResponseModel {
  final bool success;
  final String message;
  final int code;
  final dynamic data;
  final List<dynamic> metaData;

  const LogoutResponseModel({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      data: json['data'],
      metaData: (json['meta_data'] as List<dynamic>?) ?? const [],
    );
  }
}



