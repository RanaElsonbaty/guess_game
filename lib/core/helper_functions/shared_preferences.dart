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

  static Future<bool> saveGameData({
    required List<int> team1Categories,
    required List<int> team2Categories,
    required String team1Name,
    required String team2Name,
  }) async {
    final gameData = {
      'team1Categories': team1Categories,
      'team2Categories': team2Categories,
      'team1Name': team1Name,
      'team2Name': team2Name,
    };
    final gameDataJson = jsonEncode(gameData);
    return await sharedPreferences.setString(ApiConstants.GAME_DATA, gameDataJson);
  }

  static Map<String, dynamic> getGameData() {
    final gameDataJson = sharedPreferences.getString(ApiConstants.GAME_DATA);
    if (gameDataJson != null) {
      try {
        return jsonDecode(gameDataJson) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<bool> saveGameScore({
    required int team1Questions,
    required int team1Answers,
    required int team2Questions,
    required int team2Answers,
  }) async {
    final scoreData = {
      'team1Questions': team1Questions,
      'team1Answers': team1Answers,
      'team2Questions': team2Questions,
      'team2Answers': team2Answers,
    };
    return await sharedPreferences.setString(ApiConstants.GAME_SCORE, jsonEncode(scoreData));
  }

  static Map<String, dynamic> getGameScore() {
    final scoreJson = sharedPreferences.getString(ApiConstants.GAME_SCORE);
    if (scoreJson != null) {
      try {
        return jsonDecode(scoreJson) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<bool> removeGameScore() async {
    return await sharedPreferences.remove(ApiConstants.GAME_SCORE);
  }

  static Future<bool> removeGameData() async {
    return await sharedPreferences.remove(ApiConstants.GAME_DATA);
  }

  static Future<bool> saveNavigationState(String route, Map<String, dynamic>? arguments) async {
    final navState = {
      'route': route,
      'arguments': arguments ?? {},
    };
    final navStateJson = jsonEncode(navState);
    return await sharedPreferences.setString(ApiConstants.NAVIGATION_STATE, navStateJson);
  }

  static Map<String, dynamic>? getNavigationState() {
    final navStateJson = sharedPreferences.getString(ApiConstants.NAVIGATION_STATE);
    if (navStateJson != null) {
      try {
        return jsonDecode(navStateJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> clearNavigationState() async {
    return await sharedPreferences.remove(ApiConstants.NAVIGATION_STATE);
  }

  static Future<bool> saveOtpPhone(String phone) async {
    return await sharedPreferences.setString(ApiConstants.OTP_PHONE, phone);
  }

  static String? getOtpPhone() {
    return sharedPreferences.getString(ApiConstants.OTP_PHONE);
  }

  static Future<bool> removeOtpPhone() async {
    return await sharedPreferences.remove(ApiConstants.OTP_PHONE);
  }

  static Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}