import 'package:get_it/get_it.dart';
import 'package:guess_game/core/network/api_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Network
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories

  // Cubits

}
