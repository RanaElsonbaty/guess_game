class SettingsResponse {
  final bool success;
  final String message;
  final int code;
  final SettingsData data;

  SettingsResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: SettingsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SettingsData {
  final List<SettingItem> privacyPolicy;
  final List<SettingItem> termsAndConditions;
  final List<SettingItem> aboutUs;

  SettingsData({
    required this.privacyPolicy,
    required this.termsAndConditions,
    required this.aboutUs,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      privacyPolicy: (json['privacy_policy'] as List<dynamic>?)
              ?.map((e) => SettingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      termsAndConditions: (json['terms_and_conditions'] as List<dynamic>?)
              ?.map((e) => SettingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aboutUs: (json['about_us'] as List<dynamic>?)
              ?.map((e) => SettingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SettingItem {
  final String title;
  final String content;

  SettingItem({
    required this.title,
    required this.content,
  });

  factory SettingItem.fromJson(Map<String, dynamic> json) {
    return SettingItem(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}



