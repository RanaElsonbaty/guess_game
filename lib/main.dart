import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/app_routing.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/auth_cubit.dart';
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

  // Load global data
  await GlobalStorage.loadData();

  // Log initial data
  print('🚀 App Startup - Initial data:');
  print('  - Token: ${GlobalStorage.token.isNotEmpty ? "Present" : "Empty"}');
  print('  - User: ${GlobalStorage.user != null ? GlobalStorage.user!.name : "Null"}');
  print('  - Subscription: ${GlobalStorage.subscription}');

  // Determine initial route
  String initialRoute = Routes.intro;
  Object? initialArguments;

  // Check if user is logged in (has token)
  if (GlobalStorage.token.isNotEmpty) {
    try {
      // Try to get user profile from API
      final authCubit = getIt<AuthCubit>();
      await authCubit.getProfile();

      // Wait for state change
      await Future.delayed(const Duration(milliseconds: 100));

      final authState = authCubit.state;
      if (authState is ProfileLoaded) {
        final user = authState.user;
        // Update global storage with fresh data
        GlobalStorage.user = user;
        GlobalStorage.subscription = user.subscription;

        // Log profile data
        print('✅ Profile loaded successfully:');
        print('  - User: ${user.name}');
        print('  - Subscription: ${user.subscription}');
        if (user.subscription != null) {
          print('  - Subscription status: ${user.subscription!.status}');
          print('  - Subscription limit: ${user.subscription!.limit}');
        }

        // Check subscription status
        if (user.subscription != null) {
          // User has subscription, go directly to TeamCategoriesView for team category selection
          initialRoute = Routes.teamCategories;
          initialArguments = {'limit': user.subscription!.limit ?? 4};
          print('🎯 Navigation: TeamCategoriesView - فئات الفريق الأول with limit ${user.subscription!.limit ?? 4}');
          print('   📋 المستخدم مشترك: يمكنه اختيار ${user.subscription!.limit ?? 4} فئة للفريق الأول');

          // Update GlobalStorage for consistency
          GlobalStorage.subscription = user.subscription;
          print('   💾 تم تحديث GlobalStorage بالاشتراك');
        } else {
          // User logged in but no subscription, go to packages page to purchase
          initialRoute = Routes.packages;
          print('🎯 Navigation: Packages (no subscription) - عرض الباقات للشراء');
        }
      } else {
        // Profile loading failed, go to packages page as fallback
        initialRoute = Routes.packages;
        print('❌ Profile loading failed, going to packages');
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Error loading profile, go to packages page as fallback
      initialRoute = Routes.packages;
      print('❌ Profile loading error, going to packages');
    }
  } else {
    // No token, user not logged in, go to intro
    initialRoute = Routes.intro;
    print('🎯 Navigation: Intro (no token)');
  }

  print('🏁 Final navigation: $initialRoute with args: $initialArguments');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('en'),
      child: GuessGame(
        appRoutes: AppRoutes(),
        initialRoute: initialRoute,
        initialArguments: initialArguments,
      ),
    ),
  );
}
