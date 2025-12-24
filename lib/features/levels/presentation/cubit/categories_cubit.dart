import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/levels/data/repositories/categories_repository.dart';
import 'package:guess_game/features/levels/presentation/data/models/category.dart';

/// States for CategoriesCubit
abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;

  CategoriesLoaded(this.categories);
}

class CategoriesError extends CategoriesState {
  final String message;

  CategoriesError(this.message);
}

/// Cubit for managing categories state
class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _categoriesRepository;

  CategoriesCubit(this._categoriesRepository) : super(CategoriesInitial());

  /// Load categories from API
  Future<void> loadCategories() async {
    emit(CategoriesLoading());

    final result = await _categoriesRepository.getCategories();

    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  /// Get categories list (returns empty list if not loaded)
  List<Category> get categories {
    if (state is CategoriesLoaded) {
      return (state as CategoriesLoaded).categories;
    }
    return [];
  }

  /// Check if categories are loaded
  bool get isLoaded => state is CategoriesLoaded;

  /// Check if loading
  bool get isLoading => state is CategoriesLoading;

  /// Check if error occurred
  bool get hasError => state is CategoriesError;

  /// Get error message
  String? get errorMessage {
    if (state is CategoriesError) {
      return (state as CategoriesError).message;
    }
    return null;
  }
}
