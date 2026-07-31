import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_type.dart';

/// A single notification in a patient's inbox.
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.appointmentId,
    this.eventKey,
    this.readAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? appointmentId;

  /// Dedup key so the same event is not stored twice.
  final String? eventKey;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  NotificationEntity copyWith({
    String? id,
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      appointmentId: appointmentId,
      eventKey: eventKey,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        body,
        createdAt,
        appointmentId,
        eventKey,
        readAt,
      ];
}
