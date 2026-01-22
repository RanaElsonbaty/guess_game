import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/settings/data/models/settings_response.dart';
import 'package:guess_game/features/settings/data/models/social_media_response.dart';
import 'package:guess_game/features/settings/data/models/support_response.dart';
import 'package:guess_game/features/settings/data/repositories/settings_repository.dart';

part 'settings_state.dart';

/// Cubit for managing settings state
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsResponse? _settingsResponse;
  SocialMediaResponse? _socialMediaResponse;
  SupportResponse? _supportResponse;

  SettingsCubit(this._settingsRepository) : super(SettingsInitial());

  /// Load settings from API
  Future<void> loadSettings() async {
    emit(SettingsLoading());

    final result = await _settingsRepository.getSettings();

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (response) {
        _settingsResponse = response;
        emit(SettingsLoaded(response));
      },
    );
  }

  /// Get privacy policy list
  List<SettingItem> get privacyPolicy {
    if (_settingsResponse != null) {
      return _settingsResponse!.data.privacyPolicy;
    }
    return [];
  }

  /// Get terms and conditions list
  List<SettingItem> get termsAndConditions {
    if (_settingsResponse != null) {
      return _settingsResponse!.data.termsAndConditions;
    }
    return [];
  }

  /// Get about us list
  List<SettingItem> get aboutUs {
    if (_settingsResponse != null) {
      return _settingsResponse!.data.aboutUs;
    }
    return [];
  }

  /// Check if settings are loaded
  bool get isLoaded => state is SettingsLoaded;

  /// Check if loading
  bool get isLoading => state is SettingsLoading;

  /// Check if error occurred
  bool get hasError => state is SettingsError;

  /// Get error message
  String? get errorMessage {
    if (state is SettingsError) {
      return (state as SettingsError).message;
    }
    return null;
  }

  /// Load social media links from API
  Future<void> loadSocialMedia() async {
    emit(SettingsLoading());

    final result = await _settingsRepository.getSocialMedia();

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (response) {
        _socialMediaResponse = response;
        emit(SocialMediaLoaded(response));
      },
    );
  }

  /// Get social media data
  SocialMediaData? get socialMedia {
    return _socialMediaResponse?.data;
  }

  /// Check if social media is loaded
  bool get isSocialMediaLoaded => state is SocialMediaLoaded;

  /// Load support settings from API
  Future<void> loadSupportSettings() async {
    emit(SettingsLoading());

    final result = await _settingsRepository.getSupportSettings();

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (response) {
        _supportResponse = response;
        emit(SupportLoaded(response));
      },
    );
  }

  /// Get support data
  SupportData? get support {
    return _supportResponse?.data;
  }

  /// Check if support is loaded
  bool get isSupportLoaded => state is SupportLoaded;
}

