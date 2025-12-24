import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

class GlobalStorage {
  static String appLang = "";
  static String token = "";
  static UserModel? user;
  static SubscriptionModel? subscription;

  static Future<void> loadData() async {
    appLang = CacheHelper.getData(key: "myLang") as String? ?? "";
    token = CacheHelper.getToken() ?? "";
    user = CacheHelper.getUserData();
    subscription = CacheHelper.getSubscription();
  }

  static Future<void> saveUserData(UserModel userData) async {
    user = userData;
    await CacheHelper.saveUserData(userData);
  }

  static Future<void> saveToken(String tokenData) async {
    token = tokenData;
    await CacheHelper.saveToken(tokenData);
  }

  static Future<void> saveSubscription(SubscriptionModel? subscriptionData) async {
    subscription = subscriptionData;
    await CacheHelper.saveSubscription(subscriptionData);
  }

  static Future<void> clearData() async {
    await CacheHelper.clearData();
    token = "";
    appLang = "";
    user = null;
    subscription = null;
  }
}
