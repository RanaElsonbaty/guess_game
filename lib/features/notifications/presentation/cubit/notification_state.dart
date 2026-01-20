import 'package:guess_game/features/notifications/data/models/notification_messages_response.dart';

/// Base state for notification cubit
abstract class NotificationState {}

/// Initial state
class NotificationInitial extends NotificationState {}

/// Loading state
class NotificationLoading extends NotificationState {}

/// Loaded state with notification messages
class NotificationLoaded extends NotificationState {
  final NotificationMessagesResponse notificationMessages;

  NotificationLoaded(this.notificationMessages);
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}



