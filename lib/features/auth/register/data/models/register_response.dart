import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

class RegisterResponse {
  final bool success;
  final String message;
  final int code;
  final UserModel data;
  final List metaData;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: UserModel.fromJson(json['data'] as Map<String, dynamic>),
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




