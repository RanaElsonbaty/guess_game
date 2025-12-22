import 'package:dartz/dartz.dart';
import 'package:guess_game/core/network/api_failure.dart';

/// Base repository helper to convert raw calls into typed Either results.
abstract class BaseRepository {
  /// Helper to map any throwable function into Either<ApiFailure, T>.
  Future<Either<ApiFailure, T>> guardFuture<T>(
    Future<T> Function() body,
  ) async {
    try {
      final result = await body();
      return Right(result);
    } catch (e) {
      return Left(ApiFailure(e.toString()));
    }
  }
}
