import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';
import 'package:guess_game/core/network/api_service.dart';
import 'package:guess_game/core/network/base_repository.dart';
import 'package:guess_game/features/auth/otp/data/models/otp_generate_response.dart';
import 'package:guess_game/features/auth/otp/data/models/otp_verify_response.dart';

class OtpRepository extends BaseRepository {
  final ApiService _apiService;

  OtpRepository(this._apiService);

  Future<Either<ApiFailure, OtpGenerateResponse>> generateOtp({
    required String phone,
    required String takeType,
  }) async {
    print('📡 OtpRepository: إرسال طلب إلى API: /auth/otp/generate');
    print('📱 البيانات المرسلة: phone=$phone, take_type=$takeType');

    return guardFuture(() async {
      final response = await _apiService.post(
        '/auth/otp/generate',
        data: {
          'phone': phone,
          'take_type': takeType,
        },
      );

      return response.fold(
        (failure) {
          print('❌ OtpRepository: فشل الطلب: ${failure.message}');
          throw failure;
        },
        (success) {
          print('✅ OtpRepository: تم استلام الاستجابة بنجاح');
          final data = success.data;
          if (data == null) {
            print('❌ OtpRepository: لا توجد بيانات في الاستجابة');
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            print('❌ OtpRepository: تنسيق البيانات غير صحيح: ${data.runtimeType}');
            throw ApiFailure('Invalid response format');
          }

          print('📦 OtpRepository: تحليل البيانات: $data');
          return OtpGenerateResponse.fromJson(data);
        },
      );
    });
  }

  Future<Either<ApiFailure, OtpVerifyResponse>> verifyOtp({
    required String phone,
    required String otp,
    required String takeType,
  }) async {
    return guardFuture(() async {
      final response = await _apiService.post(
        '/auth/otp/verify',
        data: {
          'phone': phone,
          'otp': otp,
          'take_type': takeType,
        },
      );

      return response.fold(
        (failure) => throw failure,
        (success) {
          final data = success.data;
          if (data == null) {
            throw ApiFailure('No data received from server');
          }

          if (data is! Map<String, dynamic>) {
            throw ApiFailure('Invalid response format');
          }

          return OtpVerifyResponse.fromJson(data);
        },
      );
    });
  }
}
