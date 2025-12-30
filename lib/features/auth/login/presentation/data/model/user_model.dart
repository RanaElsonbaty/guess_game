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
  final int? id;
  final int? userId;
  final int? packageId;
  final int? paymentWebhookId;
  final DateTime? startDate;
  final String? status;
  final String? price;
  final int? points;
  final int? used;
  final int? limit;
  final int? moneyPngCount;
  final String? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  SubscriptionModel({
    this.id,
    this.userId,
    this.packageId,
    this.paymentWebhookId,
    this.startDate,
    this.status,
    this.price,
    this.points,
    this.used,
    this.limit,
    this.moneyPngCount,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  /// Factory constructor to create SubscriptionModel from JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      packageId: json['package_id'] as int?,
      paymentWebhookId: json['payment_webhook_id'] as int?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      status: json['status'] as String?,
      price: json['price'] as String?,
      points: json['points'] as int?,
      used: json['used'] as int?,
      limit: json['limit'] as int?,
      moneyPngCount: json['money_png_count'] as int?,
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert SubscriptionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'payment_webhook_id': paymentWebhookId,
      'start_date': startDate?.toIso8601String(),
      'status': status,
      'price': price,
      'points': points,
      'used': used,
      'limit': limit,
      'money_png_count': moneyPngCount,
      'payment_method': paymentMethod,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, status: $status, limit: $limit)';
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
