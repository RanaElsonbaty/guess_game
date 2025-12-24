import 'dart:convert';
import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static Future<void> appInitialization() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> cacheData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else if (value is List<String>) {
      return await sharedPreferences.setStringList(key, value);
    } else {
      return await sharedPreferences.setDouble(key, value);
    }
  }

  static Future<bool> saveToken(String token) async {
    return await sharedPreferences.setString(ApiConstants.TOKEN, token);
  }

  static String? getToken() {
    return sharedPreferences.getString(ApiConstants.TOKEN);
  }

  static Future<bool> removeToken() async {
    return await sharedPreferences.remove(ApiConstants.TOKEN);
  }

  static Future<bool> saveUserData(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    return await sharedPreferences.setString(ApiConstants.USER, userJson);
  }

  static UserModel? getUserData() {
    final userJson = sharedPreferences.getString(ApiConstants.USER);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> saveSubscription(SubscriptionModel? subscription) async {
    if (subscription == null) {
      return await sharedPreferences.remove(ApiConstants.SUBSCRIPTION);
    }
    final subscriptionJson = jsonEncode(subscription.toJson());
    return await sharedPreferences.setString(ApiConstants.SUBSCRIPTION, subscriptionJson);
  }

  static SubscriptionModel? getSubscription() {
    final subscriptionJson = sharedPreferences.getString(ApiConstants.SUBSCRIPTION);
    if (subscriptionJson != null) {
      try {
        final subscriptionMap = jsonDecode(subscriptionJson) as Map<String, dynamic>;
        return SubscriptionModel.fromJson(subscriptionMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> removeUserData() async {
    return await sharedPreferences.remove(ApiConstants.USER);
  }

  static Future<bool> removeSubscription() async {
    return await sharedPreferences.remove(ApiConstants.SUBSCRIPTION);
  }

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  static Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}
