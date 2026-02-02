import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/core/helper_functions/global_storage.dart';
import 'package:guess_game/features/auth/login/data/repositories/auth_repository.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/logout_response_model.dart';

sealed class LogoutState {}

final class LogoutInitial extends LogoutState {}

final class LogoutLoading extends LogoutState {}

final class LogoutSuccess extends LogoutState {
  final LogoutResponseModel response;
  LogoutSuccess(this.response);
}

final class LogoutError extends LogoutState {
  final String message;
  LogoutError(this.message);
}

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository _authRepository;

  LogoutCubit(this._authRepository) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());

    final result = await _authRepository.logout();
    await result.fold(
      (failure) async {
        // Even if server logout fails, we still allow clearing local session if token is gone/invalid.
        emit(LogoutError(failure.message));
      },
      (response) async {
        await GlobalStorage.clearSession();
        emit(LogoutSuccess(response));
      },
    );
  }
}






