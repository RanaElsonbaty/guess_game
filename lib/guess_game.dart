import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:guess_game/core/routing/app_routing.dart';
import 'package:guess_game/core/routing/routes.dart';

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

  @override
  State<GuessGame> createState() => _GuessGameState();
}

class _GuessGameState extends State<GuessGame> {
  @override
  void initState() {
    super.initState();

    // Handle initial route with arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialArguments != null && widget.initialRoute == Routes.teamCategories) {
        // Navigate to team categories with arguments
        Navigator.of(context).pushReplacementNamed(
          widget.initialRoute,
          arguments: widget.initialArguments,
        );
      }
    });
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
