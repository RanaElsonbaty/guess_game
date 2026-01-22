import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/settings/data/models/settings_response.dart';
import 'package:guess_game/features/settings/data/models/social_media_response.dart';
import 'package:guess_game/features/settings/data/models/support_response.dart';

/// Abstract repository interface for settings
abstract class SettingsRepository {
  /// Get privacy policy, terms and conditions, and about us
  Future<Either<ApiFailure, SettingsResponse>> getSettings();
  
  /// Get social media links
  Future<Either<ApiFailure, SocialMediaResponse>> getSocialMedia();
  
  /// Get support settings
  Future<Either<ApiFailure, SupportResponse>> getSupportSettings();
}

/// Implementation of SettingsRepository using ApiService
class SettingsRepositoryImpl extends BaseRepository implements SettingsRepository {
  final ApiService _apiService;

  SettingsRepositoryImpl(this._apiService);

  @override
  Future<Either<ApiFailure, SettingsResponse>> getSettings() async {
    return guardFuture(() async {
      developer.log(
        '📡 SettingsRepository: إرسال طلب إلى API: /settings/privacy-policy',
        name: 'SettingsRepository',
      );
      
      final response = await _apiService.get('/settings/privacy-policy');

      return response.fold(
        (failure) {
          developer.log(
            '❌ SettingsRepository: فشل الطلب: ${failure.message}',
            name: 'SettingsRepository',
            error: failure,
          );
          throw failure;
        },
        (success) {
          developer.log(
            '✅ SettingsRepository: تم استلام الاستجابة بنجاح',
            name: 'SettingsRepository',
          );
          final data = success.data;
          if (data == null) {
            developer.log(
              '❌ SettingsRepository: لا توجد بيانات في الاستجابة',
              name: 'SettingsRepository',
            );
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            developer.log(
              '❌ SettingsRepository: تنسيق البيانات غير صحيح: ${data.runtimeType}',
              name: 'SettingsRepository',
            );
            throw ApiFailure('Invalid response format');
          }

          developer.log(
            '📦 SettingsRepository: Full Response Data:',
            name: 'SettingsRepository',
          );
          developer.log(
            '  success: ${data['success']}',
            name: 'SettingsRepository',
          );
          developer.log(
            '  message: ${data['message']}',
            name: 'SettingsRepository',
          );
          developer.log(
            '  code: ${data['code']}',
            name: 'SettingsRepository',
          );
          
          final responseData = data['data'] as Map<String, dynamic>?;
          if (responseData != null) {
            developer.log(
              '📋 Privacy Policy Items: ${(responseData['privacy_policy'] as List?)?.length ?? 0}',
              name: 'SettingsRepository',
            );
            developer.log(
              '📋 Terms and Conditions Items: ${(responseData['terms_and_conditions'] as List?)?.length ?? 0}',
              name: 'SettingsRepository',
            );
            developer.log(
              '📋 About Us Items: ${(responseData['about_us'] as List?)?.length ?? 0}',
              name: 'SettingsRepository',
            );
          }
          
          return SettingsResponse.fromJson(data);
        },
      );
    });
  }

  @override
  Future<Either<ApiFailure, SocialMediaResponse>> getSocialMedia() async {
    return guardFuture(() async {
      developer.log(
        '📡 SettingsRepository: إرسال طلب إلى API: /settings/social-settings',
        name: 'SettingsRepository',
      );
      
      final response = await _apiService.get('/settings/social-settings');

      return response.fold(
        (failure) {
          developer.log(
            '❌ SettingsRepository: فشل الطلب: ${failure.message}',
            name: 'SettingsRepository',
            error: failure,
          );
          throw failure;
        },
        (success) {
          developer.log(
            '✅ SettingsRepository: تم استلام الاستجابة بنجاح',
            name: 'SettingsRepository',
          );
          final data = success.data;
          if (data == null) {
            developer.log(
              '❌ SettingsRepository: لا توجد بيانات في الاستجابة',
              name: 'SettingsRepository',
            );
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            developer.log(
              '❌ SettingsRepository: تنسيق البيانات غير صحيح: ${data.runtimeType}',
              name: 'SettingsRepository',
            );
            throw ApiFailure('Invalid response format');
          }

          developer.log(
            '📦 SettingsRepository: Full Social Media Response:',
            name: 'SettingsRepository',
          );
          developer.log(
            '  success: ${data['success']}',
            name: 'SettingsRepository',
          );
          developer.log(
            '  message: ${data['message']}',
            name: 'SettingsRepository',
          );
          developer.log(
            '  code: ${data['code']}',
            name: 'SettingsRepository',
          );
          
          final responseData = data['data'] as Map<String, dynamic>?;
          if (responseData != null) {
            developer.log(
              '📱 Social Media Links:',
              name: 'SettingsRepository',
            );
            developer.log(
              '  facebook: ${responseData['facebook']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '  instagram: ${responseData['instagram']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '  twitter: ${responseData['twitter']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '  snapchat: ${responseData['snapchat']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '  linkedin: ${responseData['linkedin']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '  youtube: ${responseData['youtube']}',
              name: 'SettingsRepository',
            );
          }
          
          return SocialMediaResponse.fromJson(data);
        },
      );
    });
  }

  @override
  Future<Either<ApiFailure, SupportResponse>> getSupportSettings() async {
    return guardFuture(() async {
      developer.log(
        '📡 SettingsRepository: إرسال طلب إلى API: /settings/support-settings',
        name: 'SettingsRepository',
      );
      
      final response = await _apiService.get('/settings/support-settings');

      return response.fold(
        (failure) {
          developer.log(
            '❌ SettingsRepository: فشل الطلب: ${failure.message}',
            name: 'SettingsRepository',
            error: failure,
          );
          throw failure;
        },
        (success) {
          developer.log(
            '✅ SettingsRepository: تم استلام الاستجابة بنجاح',
            name: 'SettingsRepository',
          );
          final data = success.data;
          if (data == null) {
            developer.log(
              '❌ SettingsRepository: لا توجد بيانات في الاستجابة',
              name: 'SettingsRepository',
            );
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            developer.log(
              '❌ SettingsRepository: تنسيق البيانات غير صحيح: ${data.runtimeType}',
              name: 'SettingsRepository',
            );
            throw ApiFailure('Invalid response format');
          }

          developer.log(
            '📦 SettingsRepository: Full Support Response:',
            name: 'SettingsRepository',
          );
          developer.log(
            '  success: ${data['success']}',
            name: 'SettingsRepository',
          );
          developer.log(
            '  message: ${data['message']}',
            name: 'SettingsRepository',
          );
          developer.log(
            '  code: ${data['code']}',
            name: 'SettingsRepository',
          );
          
          final responseData = data['data'] as Map<String, dynamic>?;
          if (responseData != null) {
            developer.log(
              '📧 Support Email: ${responseData['support_email']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '📱 Support Phone: ${responseData['support_phone']}',
              name: 'SettingsRepository',
            );
            developer.log(
              '📍 Support Address: ${responseData['support_address']}',
              name: 'SettingsRepository',
            );
          }
          
          return SupportResponse.fromJson(data);
        },
      );
    });
  }
}

