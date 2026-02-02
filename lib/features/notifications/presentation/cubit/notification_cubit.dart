import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_game/features/notifications/data/repositories/notification_repository.dart';
import 'package:guess_game/features/notifications/presentation/cubit/notification_state.dart';

/// Cubit for managing notification messages
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  /// Get notification messages from API
  Future<void> getNotificationMessages() async {
    emit(NotificationLoading());

    final result = await _repository.getNotificationMessages();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notificationMessages) => emit(NotificationLoaded(notificationMessages)),
    );
  }
}






