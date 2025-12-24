import 'package:dartz/dartz.dart';
import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/levels/presentation/data/models/category.dart';

/// Abstract repository interface for categories
abstract class CategoriesRepository {
  /// Get all categories from API
  Future<Either<ApiFailure, List<Category>>> getCategories();
}

/// Implementation of CategoriesRepository using ApiService
class CategoriesRepositoryImpl extends BaseRepository implements CategoriesRepository {
  final ApiService _apiService;

  CategoriesRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiFailure, List<Category>>> getCategories() async {
    return guardFuture(() async {
      final response = await _apiService.get(ApiConstants.categories);

      return response.fold(
        (failure) => throw failure,
        (success) {
          final data = success.data;
          if (data == null) {
            throw ApiFailure('No data received from server');
          }

          // Check if response has the expected structure
          if (data is! Map<String, dynamic>) {
            throw ApiFailure('Invalid response format');
          }

          // Check for success status
          final isSuccess = data['success'] as bool?;
          if (isSuccess != true) {
            final message = data['message'] as String? ?? 'Request failed';
            throw ApiFailure(message);
          }

          // Extract categories data
          final categoriesData = data['data'];
          if (categoriesData == null) {
            throw ApiFailure('No categories data found');
          }

          if (categoriesData is! List) {
            throw ApiFailure('Categories data is not a list');
          }

          // Parse categories
          final categories = categoriesData
              .map((categoryJson) {
                if (categoryJson is! Map<String, dynamic>) {
                  throw ApiFailure('Invalid category format');
                }
                return Category.fromJson(categoryJson);
              })
              .toList();

          return categories;
        },
      );
    });
  }
}
