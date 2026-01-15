import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/terms/data/models/game_terms_response.dart';
import 'package:guess_game/features/terms/data/repositories/terms_repository.dart';

part 'terms_state.dart';

/// Cubit for managing terms state
class TermsCubit extends Cubit<TermsState> {
  final TermsRepository _termsRepository;
  GameTermsResponse? _gameTermsResponse;

  TermsCubit(this._termsRepository) : super(TermsInitial());

  /// Load game terms from API
  Future<void> loadGameTerms() async {
    emit(TermsLoading());

    final result = await _termsRepository.getGameTerms();

    result.fold(
      (failure) => emit(TermsError(failure.message)),
      (response) {
        _gameTermsResponse = response;
        emit(TermsLoaded(response));
      },
    );
  }

  /// Get game terms list (returns empty list if not loaded)
  List<String> get gameTerms {
    try {
      if (_gameTermsResponse != null) {
        return _gameTermsResponse!.data.gameTerms;
      }
      return [];
    } catch (e) {
      print('❌ Error in gameTerms getter: $e');
      return [];
    }
  }

  /// Get formatted terms text for dialog display
  String get formattedTermsText {
    try {
      // إذا كانت البيانات محملة، اعرضها
      if (isLoaded && _gameTermsResponse != null) {
        return _gameTermsResponse!.data.gameTerms.join('\n\n');
      }

      // إذا كانت في حالة تحميل، اعرض رسالة تحميل
      if (isLoading) {
        return 'جاري تحميل شروط اللعبة...';
      }

      // إذا كان هناك خطأ، اعرض رسالة الخطأ مع معلومات إضافية
      if (hasError) {
        return 'حدث خطأ في تحميل شروط اللعبة\n\n${errorMessage ?? 'يرجى المحاولة مرة أخرى'}';
      }

      // في الحالة الافتراضية، اعرض النص الافتراضي
      return 'شروط اللعبه هتتكتب هنا و هيبان فيها كل الشروط اللازمه للعبه';
    } catch (e) {
      print('❌ Error in formattedTermsText: $e');
      return 'حدث خطأ في عرض شروط اللعبة';
    }
  }

  /// Check if terms are loaded
  bool get isLoaded => state is TermsLoaded;

  /// Check if loading
  bool get isLoading => state is TermsLoading;

  /// Check if error occurred
  bool get hasError => state is TermsError;

  /// Get error message
  String? get errorMessage {
    if (state is TermsError) {
      return (state as TermsError).message;
    }
    return null;
  }

  /// Retry loading game terms (useful for error recovery)
  Future<void> retryLoadGameTerms() async {
    if (hasError || state is TermsInitial) {
      await loadGameTerms();
    }
  }
}
