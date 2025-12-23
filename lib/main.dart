import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/app_routing.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/guess_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force landscape orientation for the game
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  await EasyLocalization.ensureInitialized();
  await CacheHelper.appInitialization();
  await setupServiceLocator();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('en'),
      child: GuessGame(
        appRoutes: AppRoutes(),
        initialRoute: Routes.groups,
      ),
    ),
  );
}
