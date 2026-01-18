import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/Intro/presentation/view/intro_view.dart';
import 'package:guess_game/features/Intro/presentation/view/start_view.dart';
import 'package:guess_game/features/auth/register/presentation/view/register_view.dart';
import 'package:guess_game/features/auth/otp/presentation/view/otp_view.dart';
import 'package:guess_game/features/auth/choose_login_type/presentation/view/choose_login_type_view.dart';
import 'package:guess_game/features/auth/login/presentation/view/login_email_view.dart';
import 'package:guess_game/features/auth/login/presentation/view/login_view.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/login_otp_cubit.dart';
import 'package:guess_game/features/auth/otp/presentation/view/otp_verify_view.dart';
import 'package:guess_game/features/auth/otp/presentation/cubit/otp_cubit.dart';
import 'package:guess_game/features/about/presentation/view/about_view.dart';
import 'package:guess_game/features/groups/presentation/view/groups_view.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/levels_view.dart';
import 'package:guess_game/features/packages/presentation/cubit/packages_cubit.dart';
import 'package:guess_game/features/packages/presentation/view/packages_view.dart';
import 'package:guess_game/features/packages/presentation/view/team_categories_second_team_view.dart';
import 'package:guess_game/features/packages/presentation/view/team_categories_first_team_view.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/game_level/presentation/view/game_level_view.dart';
import 'package:guess_game/features/qrcode/presentation/view/qrcode_view.dart';
import 'package:guess_game/features/qrcode/presentation/view/qr_image_view.dart';
import 'package:guess_game/features/qrcode/presentation/view/round_winner_view.dart';
import 'package:guess_game/features/qrcode/presentation/view/score_view.dart';
import 'package:guess_game/features/qrcode/presentation/view/game_winner_view.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:guess_game/guess_game.dart';

class AppRoutes {
  Route generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.intro:
        return _createSmoothPageRoute(IntroView(), settings: routeSettings);
      case Routes.start:
        return _createSmoothPageRoute(StartView(), settings: routeSettings);
      case Routes.register:
        return _createSmoothPageRoute(RegisterView(), settings: routeSettings);
      case Routes.otp:
        return _createSmoothPageRoute(OtpView(), settings: routeSettings);
      case Routes.otpVerify:
        final phone = routeSettings.arguments as String? ?? '';
        return _createSmoothPageRoute(
          BlocProvider<OtpCubit>(
            create: (context) => getIt<OtpCubit>(),
            child: OtpVerifyView(phone: phone),
          ),
          settings: routeSettings,
        );
      case Routes.login:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        final phone = args['phone'] as String? ?? '';
        final otp = args['otp'] as String? ?? '';
        return _createSmoothPageRoute(
          BlocProvider<LoginOtpCubit>(
            create: (context) => getIt<LoginOtpCubit>(),
            child: LoginView(phone: phone, otp: otp),
          ),
          settings: routeSettings,
        );
      case Routes.emailLogin:
        return _createSmoothPageRoute(LoginEmailView(), settings: routeSettings);
      case Routes.chooseLoginType:
        return _createSmoothPageRoute(ChooseLoginTypeView(), settings: routeSettings);
      case Routes.about:
        return _createSmoothPageRoute(AboutView(), settings: routeSettings);
      case Routes.level:
        return _createSmoothPageRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider<CategoriesCubit>(
                create: (context) => getIt<CategoriesCubit>()..loadCategories(),
              ),
              BlocProvider<NotificationCubit>(
                create: (context) => getIt<NotificationCubit>(),
              ),
            ],
            child: LevelsView(),
          ),
          settings: routeSettings,
        );
      case Routes.groups:
        return _createSmoothPageRoute(
          BlocProvider<GameCubit>(
            create: (context) => getIt<GameCubit>(),
            child: GroupsView(),
          ),
          settings: routeSettings,
        );
      case Routes.packages:
        return _createSmoothPageRoute(
          BlocProvider<PackagesCubit>(
            create: (context) => getIt<PackagesCubit>()..loadPackages(),
            child: PackagesView(),
          ),
          settings: routeSettings,
        );
      case Routes.teamCategories:
        print('📋 AppRoutes: تم استدعاء teamCategories (الفريق الأول)');
        print('📋 routeSettings.arguments: ${routeSettings.arguments}');
        print('📋 GuessGame.globalInitialArguments: ${GuessGame.globalInitialArguments}');

        // حساب limit من subscription remaining (عدد الفئات المسموح لكل فريق)
        int limit;
        final userSubscription = GlobalStorage.subscription;
        final remaining = userSubscription != null && userSubscription.status == 'active'
            ? (userSubscription.limit ?? 0) - (userSubscription.used ?? 0)
            : 0;

        // limit لكل فريق = remaining
        limit = remaining;

        // استخدم limit المحسوب، أو اقرأ من arguments كـ fallback
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          limit = args['limit'] as int? ?? limit;
          print('📋 تم قراءة limit من routeSettings Map: $limit (remaining: $remaining)');
        } else if (GuessGame.globalInitialArguments is Map<String, dynamic>) {
          final args = GuessGame.globalInitialArguments as Map<String, dynamic>;
          limit = args['limit'] as int? ?? limit;
          print('📋 تم قراءة limit من globalInitialArguments Map: $limit (remaining: $remaining)');
        } else {
          limit = routeSettings.arguments as int? ?? limit;
          print('📋 تم قراءة limit من int: $limit (remaining: $remaining)');
        }

        print('📋 Subscription remaining (limit per team): $remaining');

        return _createSmoothPageRoute(
          BlocProvider<CategoriesCubit>(
            create: (context) => getIt<CategoriesCubit>()..loadCategories(),
            child: TeamCategoriesFirstTeamView(limit: limit),
          ),
          settings: routeSettings,
        );
      case Routes.teamCategoriesSecondTeam:
        print('📋 AppRoutes: تم استدعاء teamCategoriesSecondTeam');
        print('📋 routeSettings.arguments: ${routeSettings.arguments}');

        int limit = 0;
        List<int> team1Categories = [];

        // حساب limit من subscription remaining (عدد الفئات المسموح لكل فريق)
        final userSubscription = GlobalStorage.subscription;
        final remaining = userSubscription != null && userSubscription.status == 'active'
            ? (userSubscription.limit ?? 0) - (userSubscription.used ?? 0)
            : 0;

        // التحقق من نوع البيانات المرسلة
        if (routeSettings.arguments is Map<String, dynamic>) {
          // البيانات تأتي من TeamCategoriesFirstTeamView (Map)
          final args = routeSettings.arguments as Map<String, dynamic>;
          limit = args['limit'] as int? ?? remaining;
          team1Categories = args['team1Categories'] as List<int>? ?? [];
        } else if (routeSettings.arguments is int) {
          // البيانات تأتي من team_categories_first_team_view.dart (int فقط)
          limit = routeSettings.arguments as int;
          team1Categories = []; // فارغ للفريق الثاني
        }

        print('📋 تم تحليل الـ arguments:');
        print('📋 - نوع البيانات: ${routeSettings.arguments.runtimeType}');
        print('📋 - limit: $limit');
        print('📋 - team1Categories: $team1Categories');

        // تمرير team1Categories إلى الصفحة الثانية
        print('🔄 إنشاء TeamCategoriesSecondTeamView...');
        print('🔄 limit: $limit');
        print('🔄 team1Categories: $team1Categories');

        return _createSmoothPageRoute(
          BlocProvider<CategoriesCubit>(
            create: (context) => getIt<CategoriesCubit>()..loadCategories(),
            child: TeamCategoriesSecondTeamView(
              limit: limit,
              team1Categories: team1Categories,
            ),
          ),
          settings: routeSettings,
        );
      case Routes.gameLevel:
        print('🎯 AppRoutes: تم استدعاء gameLevel');
        print('🎯 routeSettings.arguments: ${routeSettings.arguments}');

        // حفظ arguments في globalInitialArguments للاستخدام في GameLevelView
        if (routeSettings.arguments != null) {
          GuessGame.globalInitialArguments = routeSettings.arguments;
          print('🎯 تم حفظ arguments في globalInitialArguments: ${GuessGame.globalInitialArguments}');
        }

        return _createSmoothPageRoute(
          const GameLevelViewWithProvider(),
          settings: routeSettings,
        );
      case Routes.qrcodeView:
        print('🎯 AppRoutes: تم استدعاء qrcodeView');
        print('🎯 routeSettings.arguments: ${routeSettings.arguments}');

        // حفظ arguments في globalInitialArguments للاستخدام في QrcodeView
        if (routeSettings.arguments != null) {
          GuessGame.globalInitialArguments = routeSettings.arguments;
          print('🎯 تم حفظ arguments في globalInitialArguments: ${GuessGame.globalInitialArguments}');
        }

        return _createSmoothPageRoute(
          const QrcodeViewWithProvider(),
          settings: routeSettings,
        );
      case Routes.qrimageView:
        print('🎯 AppRoutes: تم استدعاء qrimageView');
        print('🎯 routeSettings.arguments: ${routeSettings.arguments}');

        if (routeSettings.arguments != null) {
          GuessGame.globalInitialArguments = routeSettings.arguments;
          print('🎯 تم حفظ arguments في globalInitialArguments: ${GuessGame.globalInitialArguments}');
        }

        return _createSmoothPageRoute(
          const QrImageView(),
          settings: routeSettings,
        );
      case Routes.roundWinnerView:
        print('🎯 AppRoutes: تم استدعاء roundWinnerView');
        print('🎯 routeSettings.arguments: ${routeSettings.arguments}');

        return _createSmoothPageRoute(
          const RoundWinnerView(),
          settings: routeSettings,
        );
      case Routes.scoreView:
        print('🎯 AppRoutes: تم استدعاء scoreView');
        print('🎯 routeSettings.arguments: ${routeSettings.arguments}');

        return _createSmoothPageRoute(
          const ScoreView(),
          settings: routeSettings,
        );
      case Routes.gameWinnerView:
        print('🏆 AppRoutes: تم استدعاء gameWinnerView');

        return _createSmoothPageRoute(
          const GameWinnerView(),
          settings: routeSettings,
        );
      default:
        return _createSmoothPageRoute(Container(), settings: routeSettings);
    }
  }

  PageRouteBuilder _createSmoothPageRoute(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve)).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
