import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

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
  static int team1Questions = 0;
  static int team1Answers = 0;
  static int team2Questions = 0;
  static int team2Answers = 0;

  static Future<void> loadData() async {
    appLang = CacheHelper.getData(key: "myLang") as String? ?? "";
    token = CacheHelper.getToken() ?? "";
    user = CacheHelper.getUserData();
    subscription = CacheHelper.getSubscription();
    final score = CacheHelper.getGameScore();
    team1Questions = score['team1Questions'] as int? ?? 0;
    team1Answers = score['team1Answers'] as int? ?? 0;
    team2Questions = score['team2Questions'] as int? ?? 0;
    team2Answers = score['team2Answers'] as int? ?? 0;
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
    team1Categories = (gameData['team1Categories'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    team2Categories = (gameData['team2Categories'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
    team1Name = gameData['team1Name'] ?? "";
    team2Name = gameData['team2Name'] ?? "";
  }

  static Future<void> saveGameScore({
    required int t1Questions,
    required int t1Answers,
    required int t2Questions,
    required int t2Answers,
  }) async {
    team1Questions = t1Questions;
    team1Answers = t1Answers;
    team2Questions = t2Questions;
    team2Answers = t2Answers;
    await CacheHelper.saveGameScore(
      team1Questions: t1Questions,
      team1Answers: t1Answers,
      team2Questions: t2Questions,
      team2Answers: t2Answers,
    );
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
    team1Questions = 0;
    team1Answers = 0;
    team2Questions = 0;
    team2Answers = 0;
  }

  /// Prints the current token to logs (debug only).
  /// Use [full] to log the entire token; otherwise it will be redacted.
  static void debugPrintToken({bool full = false}) {
    if (!kDebugMode) return;
    final t = token;
    if (t.isEmpty) {
      developer.log('Token: <empty>', name: 'Auth');
      return;
    }
    developer.log('Token: ${full ? t : _redactToken(t)}', name: 'Auth');
  }

  // Redacts a token for safer logging while keeping it identifiable.
  static String _redactToken(String t, {int keepStart = 6, int keepEnd = 4}) {
    if (t.isEmpty) return t;
    if (keepStart < 0) keepStart = 0;
    if (keepEnd < 0) keepEnd = 0;
    if (t.length <= keepStart + keepEnd + 3) return t;
    return '${t.substring(0, keepStart)}...${t.substring(t.length - keepEnd)}';
  }
}