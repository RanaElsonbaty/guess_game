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

  // Game responses
  static dynamic gameStartResponse;

  // Current round tracking
  static int currentRoundIndex = 0;

  // Last used round data IDs for incrementing
  static int lastTeam1RoundDataId = 0;
  static int lastTeam2RoundDataId = 0;

  // Navigation state persistence
  static String lastRoute = "";
  static Map<String, dynamic> lastRouteArguments = {};

  // Essential data for route restoration
  static int? lastLimit;
  static List<int>? lastTeam1Categories;
  static dynamic lastGameStartResponse;

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

    // Load navigation state
    await loadNavigationState();
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

  static Future<void> saveGameStartResponse(dynamic response) async {
    gameStartResponse = response;
    // Reset round index when starting a new game
    currentRoundIndex = 0;
    // Note: We're not saving to cache since it's a complex object
    // It will be available during the app session
  }

  static int getCurrentRoundId() {
    if (gameStartResponse == null || gameStartResponse.data.rounds == null) {
      return 0;
    }
    final rounds = gameStartResponse.data.rounds;
    if (currentRoundIndex < rounds.length) {
      return rounds[currentRoundIndex].id;
    }
    return 0;
  }

  static int getNextRoundNumber() {
    return currentRoundIndex + 2; // Next round number (1-based + 1)
  }

  static void moveToNextRound() {
    currentRoundIndex++;
  }

  static void updateLastRoundDataIds(int team1Id, int team2Id) {
    lastTeam1RoundDataId = team1Id;
    lastTeam2RoundDataId = team2Id;
  }

  static int getNextTeam1RoundDataId() {
    return lastTeam1RoundDataId + 1;
  }

  static int getNextTeam2RoundDataId() {
    return lastTeam2RoundDataId + 1;
  }

  static void saveNavigationState(String route, Map<String, dynamic>? arguments) {
    lastRoute = route;
    lastRouteArguments = arguments ?? {};

    // Extract and save essential data based on route
    switch (route) {
      case 'team_categories':
        lastLimit = arguments?['limit'] as int?;
        break;
      case 'team_categories_second_team':
        lastLimit = arguments?['limit'] as int?;
        lastTeam1Categories = arguments?['team1Categories'] as List<int>?;
        break;
      case 'game_level':
        lastGameStartResponse = arguments?['gameStartResponse'];
        break;
    }

    // Merge essential data with arguments for saving
    final extendedArgs = Map<String, dynamic>.from(arguments ?? {});
    extendedArgs['limit'] = lastLimit;
    extendedArgs['team1Categories'] = lastTeam1Categories;
    extendedArgs['gameStartResponse'] = lastGameStartResponse;

    // Save to persistent storage
    CacheHelper.saveNavigationState(route, extendedArgs);
  }

  static Future<void> loadNavigationState() async {
    final navState = CacheHelper.getNavigationState();
    if (navState != null) {
      lastRoute = navState['route'] ?? "";
      lastRouteArguments = navState['arguments'] ?? {};

      // Load essential data
      lastLimit = navState['limit'] as int?;
      lastTeam1Categories = navState['team1Categories'] as List<int>?;
      lastGameStartResponse = navState['gameStartResponse'];
    }
  }

  static void clearNavigationState() {
    lastRoute = "";
    lastRouteArguments = {};
    CacheHelper.clearNavigationState();
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
    gameStartResponse = null;
    currentRoundIndex = 0;
    lastTeam1RoundDataId = 0;
    lastTeam2RoundDataId = 0;
    lastRoute = "";
    lastRouteArguments = {};
    lastLimit = null;
    lastTeam1Categories = null;
    lastGameStartResponse = null;
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