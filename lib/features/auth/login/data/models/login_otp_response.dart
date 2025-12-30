import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

class LoginOtpResponse {
  final bool success;
  final String message;
  final int code;
  final LoginOtpData data;
  final List metaData;

  LoginOtpResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    return LoginOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: LoginOtpData.fromJson(json['data'] as Map<String, dynamic>),
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

class LoginOtpData {
  final UserModel user;
  final String token;

  LoginOtpData({
    required this.user,
    required this.token,
  });

  factory LoginOtpData.fromJson(Map<String, dynamic> json) {
    return LoginOtpData(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}

