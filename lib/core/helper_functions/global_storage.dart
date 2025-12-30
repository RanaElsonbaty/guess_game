import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

class GlobalStorage {
  static String appLang = "";
  static String token = "";
  static UserModel? user;
  static SubscriptionModel? subscription;

  // Game data
  static List<int> team1Categories = [];
  static List<int> team2Categories = [];
  static String team1Name = "";
  static String team2Name = "";

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

  static Future<void> saveGameData({
    required List<int> team1Cats,
    required List<int> team2Cats,
    required String t1Name,
    required String t2Name,
  }) async {
    team1Categories = team1Cats;
    team2Categories = team2Cats;
    team1Name = t1Name;
    team2Name = t2Name;

    await CacheHelper.saveGameData(
      team1Categories: team1Cats,
      team2Categories: team2Cats,
      team1Name: t1Name,
      team2Name: t2Name,
    );
  }

  static Future<void> loadGameData() async {
    final gameData = CacheHelper.getGameData();
    team1Categories = gameData['team1Categories'] ?? [];
    team2Categories = gameData['team2Categories'] ?? [];
    team1Name = gameData['team1Name'] ?? "";
    team2Name = gameData['team2Name'] ?? "";
  }

  static Future<void> clearData() async {
    await CacheHelper.clearData();
    token = "";
    appLang = "";
    user = null;
    subscription = null;
    team1Categories = [];
    team2Categories = [];
    team1Name = "";
    team2Name = "";
  }
}