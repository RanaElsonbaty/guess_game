import 'package:guess_game/core/helper_functions/api_constants.dart';
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
