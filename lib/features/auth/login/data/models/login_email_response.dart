import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

class LoginEmailResponse {
  final bool success;
  final String message;
  final int code;
  final LoginEmailData data;
  final List metaData;

  LoginEmailResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory LoginEmailResponse.fromJson(Map<String, dynamic> json) {
    return LoginEmailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: LoginEmailData.fromJson(json['data'] as Map<String, dynamic>),
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

class LoginEmailData {
  final UserModel user;
  final String token;

  LoginEmailData({
    required this.user,
    required this.token,
  });

  factory LoginEmailData.fromJson(Map<String, dynamic> json) {
    return LoginEmailData(
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




