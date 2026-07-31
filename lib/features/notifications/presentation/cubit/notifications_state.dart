import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}
