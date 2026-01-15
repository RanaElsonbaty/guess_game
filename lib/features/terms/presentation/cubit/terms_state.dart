part of 'terms_cubit.dart';

/// States for TermsCubit
abstract class TermsState {}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {
  final GameTermsResponse response;

  TermsLoaded(this.response);
}

class TermsError extends TermsState {
  final String message;

  TermsError(this.message);
}
