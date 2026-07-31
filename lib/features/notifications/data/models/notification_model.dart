import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_type.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    required super.createdAt,
    super.appointmentId,
    super.eventKey,
    super.readAt,
  });

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      createdAt: entity.createdAt,
      appointmentId: entity.appointmentId,
      eventKey: entity.eventKey,
      readAt: entity.readAt,
    );
  }

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: NotificationType.fromName(data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      appointmentId: data['appointmentId'] as String?,
      eventKey: data['eventKey'] as String?,
      readAt: _parseTimestamp(data['readAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      if (appointmentId != null) 'appointmentId': appointmentId,
      if (eventKey != null) 'eventKey': eventKey,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
    };
  }

  static DateTime? _parseTimestamp(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
