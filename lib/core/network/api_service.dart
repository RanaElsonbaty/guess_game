import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:guess_game/core/helper_functions/api_constants.dart';
import 'package:guess_game/core/helper_functions/shared_preferences.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/guess_game.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.BASE_URL,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            ),
          ) {
    // Add interceptor to include token and language in headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Authorization token
          final token = CacheHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add Accept-Language header based on current locale
          try {
            final context = GuessGame.navKey.currentContext;
            if (context != null) {
              final currentLocale = EasyLocalization.of(context)?.locale;
              if (currentLocale != null) {
                final languageCode = currentLocale.languageCode;
                options.headers['Accept-Language'] = languageCode == 'ar'
                    ? 'ar'
                    : 'en';
              } else {
                // Fallback to Arabic if locale is not available
                options.headers['Accept-Language'] = 'ar';
              }
            } else {
              // Fallback to Arabic if context is not available
              options.headers['Accept-Language'] = 'ar';
            }
          } catch (e) {
            // Fallback to Arabic if there's an error
            options.headers['Accept-Language'] = 'ar';
          }

          return handler.next(options);
        },
      ),
    );
  }

  /// GET request
  Future<Either<ApiFailure, Response<dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// POST request
  Future<Either<ApiFailure, Response<dynamic>>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// PUT request
  Future<Either<ApiFailure, Response<dynamic>>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// PATCH request
  Future<Either<ApiFailure, Response<dynamic>>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// DELETE request
  Future<Either<ApiFailure, Response<dynamic>>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }

  /// Map DioException to readable ApiFailure
  ApiFailure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    String message;

    // Try to extract message from response body
    if (e.response?.data != null) {
      try {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          // Extract message from API response
          if (responseData.containsKey('message') &&
              responseData['message'] != null) {
            message = responseData['message'].toString();
            return ApiFailure(message, statusCode: statusCode);
          }
          // Fallback to errors field if message not found
          if (responseData.containsKey('errors') &&
              responseData['errors'] != null) {
            message = responseData['errors'].toString();
            return ApiFailure(message, statusCode: statusCode);
          }
        }
      } catch (_) {
        // If parsing fails, continue to default messages
      }
    }

    // Default messages based on error type
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'انتهت مهلة الاتصال، حاول مرة أخرى';
        break;
      case DioExceptionType.badResponse:
        message = 'خطأ من الخادم (${statusCode ?? 0})';
        break;
      case DioExceptionType.cancel:
        message = 'تم إلغاء الطلب';
        break;
      default:
        message = 'حدث خطأ غير متوقع';
    }

    return ApiFailure(message, statusCode: statusCode);
  }
}
