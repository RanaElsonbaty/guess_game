import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/auth/login/data/repositories/auth_repository.dart';
import 'package:guess_game/features/auth/login/presentation/data/model/user_model.dart';

/// States for AuthCubit
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  Authenticated(this.user);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class ProfileLoading extends AuthState {}

class ProfileLoaded extends AuthState {
  final UserModel user;

  ProfileLoaded(this.user);
}

class ProfileError extends AuthState {
  final String message;

  ProfileError(this.message);
}

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    final result = await _authRepository.login(email, password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (loginResponse) => emit(Authenticated(loginResponse.data.user)),
    );
  }

  /// Get user profile
  Future<void> getProfile() async {
    emit(ProfileLoading());

    final result = await _authRepository.getProfile();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }
}
