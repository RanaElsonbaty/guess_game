import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/routing/app_routing.dart';

class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _saveCurrentRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _saveCurrentRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _saveCurrentRoute(newRoute);
    }
  }

  void _saveCurrentRoute(Route route) {
    final routeName = route.settings.name;
    final arguments = route.settings.arguments;
    if (routeName != null && routeName.isNotEmpty) {
      // Serialize arguments to avoid JSON encoding issues with complex objects
      final safeArguments = _serializeArguments(arguments);
      GlobalStorage.saveNavigationState(routeName, safeArguments);
      print('💾 NavigationObserver: تم حفظ الصفحة - $routeName مع arguments: $safeArguments');
    }
  }

  Map<String, dynamic>? _serializeArguments(dynamic arguments) {
    if (arguments == null) return null;

    // If arguments is already a Map, process it
    if (arguments is Map<String, dynamic>) {
      final safeArgs = Map<String, dynamic>.from(arguments);

      // Convert complex objects to their JSON representation if they have toJson method
      safeArgs.forEach((key, value) {
        if (value != null && value is! String && value is! int && value is! double && value is! bool && value is! List) {
          try {
            // Try to call toJson if the object has it
            if (value.toString().contains('Instance of')) {
              // Skip complex objects that can't be serialized
              safeArgs[key] = null;
            } else if (value is Map || value is List) {
              // Keep maps and lists as they might be serializable
            } else {
              safeArgs[key] = value.toString();
            }
          } catch (e) {
            // If serialization fails, set to null
            safeArgs[key] = null;
          }
        }
      });

      return safeArgs;
    }

    // If arguments is not a Map, wrap it in a Map with a generic key
    return {'value': arguments.toString()};
  }
}

class GuessGame extends StatefulWidget {
  final AppRoutes appRoutes;
  final String initialRoute;
  final Object? initialArguments;
  const GuessGame({
    super.key,
    required this.appRoutes,
    required this.initialRoute,
    this.initialArguments,
  });
  static GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  // Store initial arguments globally
  static Object? globalInitialArguments;

  @override
  State<GuessGame> createState() => _GuessGameState();
}

class _GuessGameState extends State<GuessGame> {
  @override
  void initState() {
    super.initState();

    // Store initial arguments globally
    GuessGame.globalInitialArguments = widget.initialArguments;

    print('🎯 GuessGame: تم حفظ initialArguments في globalInitialArguments: ${GuessGame.globalInitialArguments}');
  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(812, 375), // Landscape design size
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          navigatorKey: GuessGame.navKey,
          title: "Guess Game",
          theme: ThemeData(
            // fontFamily: AppFonts.neoSansArabic
          ),
          navigatorObservers: [NavigationObserver()],
          onGenerateRoute: widget.appRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
          initialRoute:  widget.initialRoute,
          builder: (context, child) {
            return Directionality(
              textDirection: context.locale.languageCode == 'ar'
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
