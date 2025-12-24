import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/injection/service_locator.dart';
import 'package:guess_game/core/routing/routes.dart';
import 'package:guess_game/features/Intro/presentation/view/intro_view.dart';
import 'package:guess_game/features/Intro/presentation/view/start_view.dart';
import 'package:guess_game/features/groups/presentation/view/groups_view.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/levels/presentation/view/levels_view.dart';
import 'package:guess_game/features/packages/presentation/cubit/packages_cubit.dart';
import 'package:guess_game/features/packages/presentation/view/packages_view.dart';

class AppRoutes {
  Route generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.intro:
        return _createSmoothPageRoute(IntroView());
      case Routes.start:
        return _createSmoothPageRoute(StartView());
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
