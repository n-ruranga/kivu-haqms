import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationEntity> createNotification(NotificationEntity notification);

  Stream<List<NotificationEntity>> watchNotificationsForUser(String userId);

  Future<bool> existsByEventKey({
    required String userId,
    required String eventKey,
  });

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);
}
