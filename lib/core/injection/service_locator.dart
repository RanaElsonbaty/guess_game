import 'package:get_it/get_it.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/features/auth/login/data/repositories/auth_repository.dart';
import 'package:guess_game/features/auth/login/data/repositories/login_email_repository.dart';
import 'package:guess_game/features/auth/login/data/repositories/login_otp_repository.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/auth_cubit.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/logout_cubit.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/login_email_cubit.dart';
import 'package:guess_game/features/about/presentation/cubit/about_cubit.dart';
import 'package:guess_game/features/auth/login/presentation/cubit/login_otp_cubit.dart';
import 'package:guess_game/features/auth/otp/data/repositories/otp_repository.dart';
import 'package:guess_game/features/auth/otp/presentation/cubit/otp_cubit.dart';
import 'package:guess_game/features/auth/register/data/repositories/register_repository.dart';
import 'package:guess_game/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:guess_game/features/levels/data/repositories/categories_repository.dart';
import 'package:guess_game/features/levels/presentation/cubit/categories_cubit.dart';
import 'package:guess_game/features/packages/data/repositories/packages_repository.dart';
import 'package:guess_game/features/packages/presentation/cubit/packages_cubit.dart';
import 'package:guess_game/features/game/data/repositories/game_repository.dart';
import 'package:guess_game/features/game/presentation/cubit/game_cubit.dart';
import 'package:guess_game/features/game/presentation/cubit/repeat_game_cubit.dart';
import 'package:guess_game/features/game/presentation/cubit/add_one_round_cubit.dart';
import 'package:guess_game/features/game/presentation/cubit/get_all_games_cubit.dart';
import 'package:guess_game/features/terms/data/repositories/terms_repository.dart';
import 'package:guess_game/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:guess_game/features/notifications/data/repositories/notification_repository.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:guess_game/features/settings/data/repositories/settings_repository.dart';
import 'package:guess_game/features/settings/presentation/cubit/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Network
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<RegisterRepository>(
    () => RegisterRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<OtpRepository>(
    () => OtpRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<LoginOtpRepository>(
    () => LoginOtpRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<LoginEmailRepository>(
    () => LoginEmailRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<PackagesRepository>(
    () => PackagesRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<TermsRepository>(
    () => TermsRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<ApiService>()),
  );

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );

  getIt.registerFactory<LogoutCubit>(
    () => LogoutCubit(getIt<AuthRepository>()),
  );

  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(getIt<RegisterRepository>()),
  );

  getIt.registerFactory<OtpCubit>(
    () => OtpCubit(getIt<OtpRepository>()),
  );

  getIt.registerFactory<LoginOtpCubit>(
    () => LoginOtpCubit(getIt<LoginOtpRepository>()),
  );

  getIt.registerFactory<LoginEmailCubit>(
    () => LoginEmailCubit(getIt<LoginEmailRepository>()),
  );

  getIt.registerFactory<AboutCubit>(
    () => AboutCubit(),
  );

  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<CategoriesRepository>()),
  );

  getIt.registerFactory<PackagesCubit>(
    () => PackagesCubit(getIt<PackagesRepository>()),
  );

  getIt.registerFactory<GameCubit>(
    () => GameCubit(getIt<GameRepository>()),
  );

  getIt.registerFactory<RepeatGameCubit>(
    () => RepeatGameCubit(getIt<GameRepository>()),
  );

  getIt.registerFactory<AddOneRoundCubit>(
    () => AddOneRoundCubit(getIt<GameRepository>()),
  );

  getIt.registerFactory<GetAllGamesCubit>(
    () => GetAllGamesCubit(getIt<GameRepository>()),
  );

  getIt.registerFactory<TermsCubit>(
    () => TermsCubit(getIt<TermsRepository>()),
  );

  getIt.registerFactory<NotificationCubit>(
    () => NotificationCubit(getIt<NotificationRepository>()),
  );

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepository>()),
  );
}
