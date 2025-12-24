import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/packages/data/repositories/packages_repository.dart';
import 'package:guess_game/features/packages/presentation/data/models/package.dart';

/// States for PackagesCubit
abstract class PackagesState {}

class PackagesInitial extends PackagesState {}

class PackagesLoading extends PackagesState {}

class PackagesLoaded extends PackagesState {
  final List<Package> packages;

  PackagesLoaded(this.packages);
}

class PackagesError extends PackagesState {
  final String message;

  PackagesError(this.message);
}

/// Cubit for managing packages state
class PackagesCubit extends Cubit<PackagesState> {
  final PackagesRepository _packagesRepository;

  PackagesCubit(PackagesRepository packagesRepository)
      : _packagesRepository = packagesRepository,
        super(PackagesInitial());

  /// Load packages from API
  Future<void> loadPackages() async {
    emit(PackagesLoading());

    final result = await _packagesRepository.getPackages();

    result.fold(
      (failure) => emit(PackagesError(failure.message)),
      (packages) => emit(PackagesLoaded(packages)),
    );
  }

  /// Get packages list (returns empty list if not loaded)
  List<Package> get packages {
    if (state is PackagesLoaded) {
      return (state as PackagesLoaded).packages;
    }
    return [];
  }

  /// Check if packages are loaded
  bool get isLoaded => state is PackagesLoaded;

  /// Check if loading
  bool get isLoading => state is PackagesLoading;

  /// Check if error occurred
  bool get hasError => state is PackagesError;

  /// Get error message
  String? get errorMessage {
    if (state is PackagesError) {
      return (state as PackagesError).message;
    }
    return null;
  }
}
