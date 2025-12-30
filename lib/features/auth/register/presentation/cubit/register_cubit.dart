import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/auth/register/data/models/register_response.dart';
import 'package:guess_game/features/auth/register/data/repositories/register_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository _registerRepository;

  RegisterCubit(this._registerRepository) : super(RegisterInitial());

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(RegisterLoading());

    final result = await _registerRepository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    result.fold(
      (failure) => emit(RegisterError(failure.message)),
      (response) => emit(RegisterSuccess(response)),
    );
  }
}
