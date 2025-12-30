import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/auth/login/data/models/login_email_response.dart';
import 'package:guess_game/features/auth/login/data/repositories/login_email_repository.dart';

part 'login_email_state.dart';

class LoginEmailCubit extends Cubit<LoginEmailState> {
  final LoginEmailRepository _loginEmailRepository;

  LoginEmailCubit(this._loginEmailRepository) : super(LoginEmailInitial());

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(LoginEmailLoading());

    final result = await _loginEmailRepository.loginWithEmail(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(LoginEmailError(failure.message)),
      (response) => emit(LoginEmailSuccess(response)),
    );
  }
}
