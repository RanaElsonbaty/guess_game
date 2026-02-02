class SocialMediaResponse {
  final bool success;
  final String message;
  final int code;
  final SocialMediaData data;

  SocialMediaResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
  });

  factory SocialMediaResponse.fromJson(Map<String, dynamic> json) {
    return SocialMediaResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: SocialMediaData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SocialMediaData {
  final String? facebook;
  final String? snapchat;
  final String? twitter;
  final String? instagram;
  final String? linkedin;
  final String? youtube;

  SocialMediaData({
    this.facebook,
    this.snapchat,
    this.twitter,
    this.instagram,
    this.linkedin,
    this.youtube,
  });

  factory SocialMediaData.fromJson(Map<String, dynamic> json) {
    return SocialMediaData(
      facebook: json['facebook'] as String?,
      snapchat: json['snapchat'] as String?,
      twitter: json['twitter'] as String?,
      instagram: json['instagram'] as String?,
      linkedin: json['linkedin'] as String?,
      youtube: json['youtube'] as String?,
    );
  }
}



