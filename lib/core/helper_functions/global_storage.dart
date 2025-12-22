import 'package:guess_game/core/helper_functions/shared_preferences.dart';

class GlobalStorage {
  static String appLang = "";
  static String token = "";

  static Future<void> loadData() async {
    appLang = CacheHelper.getData(key: "myLang") as String? ?? "";
    token = CacheHelper.getToken() ?? "";
  }


  static Future<void> clearData() async {
    await CacheHelper.clearData();
    token = "";
    appLang = "";
  }
}
