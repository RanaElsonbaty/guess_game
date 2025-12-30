import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:guess_game/features/packages/presentation/view/team_categories_view.dart';
import 'package:guess_game/features/game_level/presentation/view/game_level_view.dart';

class AppRoutes {
  Route generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.intro:
        return _createSmoothPageRoute(IntroView());
      case Routes.start:
        return _createSmoothPageRoute(StartView());
      case Routes.register:
        return _createSmoothPageRoute(RegisterView());
      case Routes.otp:
        return _createSmoothPageRoute(OtpView());
      case Routes.otpVerify:
        final phone = routeSettings.arguments as String? ?? '';
        return _createSmoothPageRoute(
          BlocProvider<OtpCubit>(
            create: (context) => getIt<OtpCubit>(),
            child: OtpVerifyView(phone: phone),
          ),
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
        );
      case Routes.emailLogin:
        return _createSmoothPageRoute(LoginEmailView());
      case Routes.chooseLoginType:
        return _createSmoothPageRoute(ChooseLoginTypeView());
      case Routes.about:
        return _createSmoothPageRoute(AboutView());
      case Routes.level:
        return _createSmoothPageRoute(
          BlocProvider<CategoriesCubit>(
            create: (context) => getIt<CategoriesCubit>()..loadCategories(),
            child: LevelsView(),
          ),
        );
      case Routes.groups:
        return _createSmoothPageRoute(GroupsView());
      case Routes.packages:
        return _createSmoothPageRoute(
          BlocProvider<PackagesCubit>(
            create: (context) => getIt<PackagesCubit>()..loadPackages(),
            child: PackagesView(),
          ),
        );
      case Routes.teamCategories:
        print('📋 AppRoutes: تم استدعاء teamCategories (الفريق الأول)');
        print('📋 routeSettings.arguments: ${routeSettings.arguments}');

        // دعم كلا الطريقتين: int (من main.dart) أو Map (من pushNamed)
        int limit;
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          limit = args['limit'] as int? ?? 0;
          print('📋 تم قراءة limit من Map: $limit');
        } else {
          limit = routeSettings.arguments as int? ?? 0;
          print('📋 تم قراءة limit من int: $limit');
        }

        return _createSmoothPageRoute(
          BlocProvider<CategoriesCubit>(
            create: (context) => getIt<CategoriesCubit>()..loadCategories(),
            child: TeamCategoriesFirstTeamView(limit: limit),
          ),
        );
      case Routes.teamCategoriesSecondTeam:
        print('📋 AppRoutes: تم استدعاء teamCategoriesSecondTeam');
        print('📋 routeSettings.arguments: ${routeSettings.arguments}');

        int limit = 0;
        List<int> team1Categories = [];

        // التحقق من نوع البيانات المرسلة
        if (routeSettings.arguments is Map<String, dynamic>) {
          // البيانات تأتي من TeamCategoriesFirstTeamView (Map)
          final args = routeSettings.arguments as Map<String, dynamic>;
          limit = args['limit'] as int? ?? 0;
          team1Categories = args['team1Categories'] as List<int>? ?? [];
        } else if (routeSettings.arguments is int) {
          // البيانات تأتي من team_categories_view.dart (int فقط)
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
        );
      case Routes.gameLevel:
        return _createSmoothPageRoute(GameLevelView());
      default:
        return _createSmoothPageRoute(Container());
    }
  }

  PageRouteBuilder _createSmoothPageRoute(Widget page) {
    return PageRouteBuilder(
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
