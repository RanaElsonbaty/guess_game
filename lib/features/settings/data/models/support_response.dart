class SupportResponse {
  final bool success;
  final String message;
  final int code;
  final SupportData data;

  SupportResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
  });

  factory SupportResponse.fromJson(Map<String, dynamic> json) {
    return SupportResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: SupportData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SupportData {
  final String? supportEmail;
  final String? supportPhone;
  final String? supportAddress;

  SupportData({
    this.supportEmail,
    this.supportPhone,
    this.supportAddress,
  });

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      supportEmail: json['support_email'] as String?,
      supportPhone: json['support_phone'] as String?,
      supportAddress: json['support_address'] as String?,
    );
  }
}



