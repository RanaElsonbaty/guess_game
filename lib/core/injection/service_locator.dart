import 'package:get_it/get_it.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/features/levels/data/repositories/categories_repository.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/packages/data/repositories/packages_repository.dart';
import 'package:guess_game/features/packages/presentation/cubit/packages_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Network
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<PackagesRepository>(
    () => PackagesRepositoryImpl(getIt<ApiService>()),
  );

  // Cubits
  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<CategoriesRepository>()),
  );

  getIt.registerFactory<PackagesCubit>(
    () => PackagesCubit(getIt<PackagesRepository>()),
  );
}
