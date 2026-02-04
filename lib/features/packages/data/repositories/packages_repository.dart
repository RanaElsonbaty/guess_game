import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/packages/presentation/data/models/package.dart';

/// Abstract repository interface for packages
abstract class PackagesRepository {
  /// Get all packages from API
  Future<Either<ApiFailure, List<Package>>> getPackages();

  /// Subscribe to a package with payment
  Future<Either<ApiFailure, String>> subscribeToPackage(int packageId, {bool increase = false});

  /// Subscribe without package_id (for +1 category feature)
  Future<Either<ApiFailure, String>> subscribeWithoutPackage();
}

/// Implementation of PackagesRepository using ApiService
class PackagesRepositoryImpl extends BaseRepository implements PackagesRepository {
  final ApiService _apiService;

  PackagesRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiFailure, List<Package>>> getPackages() async {
    return guardFuture(() async {
      final response = await _apiService.get('/packages');

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

          // Extract packages data
          final packagesData = data['data'];
          if (packagesData == null) {
            throw ApiFailure('No packages data found');
          }

          if (packagesData is! List) {
            throw ApiFailure('Packages data is not a list');
          }

          // Parse packages
          final packages = packagesData
              .map((packageJson) {
                if (packageJson is! Map<String, dynamic>) {
                  throw ApiFailure('Invalid package format');
                }
                return Package.fromJson(packageJson);
              })
              .toList();

          return packages;
        },
      );
    });
  }

  @override
  Future<Either<ApiFailure, String>> subscribeToPackage(int packageId, {bool increase = false}) async {
    return guardFuture(() async {
      final dataBody = <String, dynamic>{
        'package_id': packageId,
        'payment_method': 'online',
      };
      
      // إضافة increase إذا كان true (فقط عند وجود subscription)
      if (increase) {
        dataBody['increase'] = true;
      }
      
      final response = await _apiService.post('/payment/subscribe-in-package', data: dataBody);

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
            final message = data['message'] as String? ?? 'Payment failed';
            throw ApiFailure(message);
          }

          // Extract payment URL
          final paymentUrl = data['data'] as String?;
          if (paymentUrl == null || paymentUrl.isEmpty) {
            throw ApiFailure('No payment URL received');
          }

          return paymentUrl;
        },
      );
    });
  }

  @override
  Future<Either<ApiFailure, String>> subscribeWithoutPackage() async {
    return guardFuture(() async {
      final dataBody = <String, dynamic>{
        'payment_method': 'online',
        'increase': true,
      };
      
      final response = await _apiService.post('/payment/subscribe-in-package', data: dataBody);

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
            final message = data['message'] as String? ?? 'Payment failed';
            throw ApiFailure(message);
          }

          // Extract payment URL
          final paymentUrl = data['data'] as String?;
          if (paymentUrl == null || paymentUrl.isEmpty) {
            throw ApiFailure('No payment URL received');
          }

          return paymentUrl;
        },
      );
    });
  }
}
