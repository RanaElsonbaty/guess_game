/// User model representing a user entity
class UserModel {
  final int id;
  final String name;
  final String phone;
  final DateTime? phoneVerifiedAt;
  final String email;
  final DateTime? emailVerifiedAt;
  final String? image;
  final String? address;
  final DateTime? lastLoginAt;
  final String status;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionModel? subscription;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.phoneVerifiedAt,
    required this.email,
    this.emailVerifiedAt,
    this.image,
    this.address,
    this.lastLoginAt,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.subscription,
  });

  /// Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      phoneVerifiedAt: json['phone_verified_at'] != null
          ? DateTime.parse(json['phone_verified_at'] as String)
          : null,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      image: json['image'] as String?,
      address: json['address'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      status: json['status'] as String,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'image': image,
      'address': address,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'status': status,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'subscription': subscription?.toJson(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Subscription model representing subscription data
class SubscriptionModel {
  // Add fields based on your subscription object structure
  // Since you mentioned it's an empty object {}, I'll create a flexible model
  final Map<String, dynamic>? data;

  SubscriptionModel({this.data});

  /// Factory constructor to create SubscriptionModel from JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(data: json);
  }

  /// Convert SubscriptionModel to JSON
  Map<String, dynamic> toJson() {
    return data ?? {};
  }

  @override
  String toString() {
    return 'SubscriptionModel(data: $data)';
  }
}

/// Login response model containing user and token
class LoginResponseModel {
  final bool success;
  final String message;
  final int code;
  final LoginDataModel data;
  final List<dynamic> metaData;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
    required this.metaData,
  });

  /// Factory constructor to create LoginResponseModel from JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as int,
      data: LoginDataModel.fromJson(json['data'] as Map<String, dynamic>),
      metaData: json['meta_data'] as List<dynamic>,
    );
  }

  /// Convert LoginResponseModel to JSON
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

/// Example usage for login response:
/// ```dart
/// // When receiving login API response:
/// final loginResponse = LoginResponseModel.fromJson(apiResponseJson);
/// if (loginResponse.success) {
///   // Save user data
///   await GlobalStorage.saveUserData(loginResponse.data.user);
///   // Save token
///   await GlobalStorage.saveToken(loginResponse.data.token);
///   // Save subscription (can be null)
///   await GlobalStorage.saveSubscription(loginResponse.data.user.subscription);
/// }
/// ```

/// Login data model containing user and token
class LoginDataModel {
  final UserModel user;
  final String token;

  LoginDataModel({
    required this.user,
    required this.token,
  });

  /// Factory constructor to create LoginDataModel from JSON
  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  /// Convert LoginDataModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}
