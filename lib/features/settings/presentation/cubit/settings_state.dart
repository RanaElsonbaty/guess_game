part of 'settings_cubit.dart';

/// States for SettingsCubit
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsResponse response;

  SettingsLoaded(this.response);
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}

class SocialMediaLoaded extends SettingsState {
  final SocialMediaResponse response;

  SocialMediaLoaded(this.response);
}

class SupportLoaded extends SettingsState {
  final SupportResponse response;

  SupportLoaded(this.response);
}

