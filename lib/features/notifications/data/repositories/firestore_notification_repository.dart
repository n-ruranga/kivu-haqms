import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/core/constants/firebase_constants.dart';
import 'package:kivu_haqms/features/notifications/data/models/notification_model.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/repositories/notification_repository.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  @override
  Future<NotificationEntity> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      if (notification.eventKey != null) {
        final exists = await existsByEventKey(
          userId: notification.userId,
          eventKey: notification.eventKey!,
        );
        if (exists) {
          return notification;
        }
      }

      final model = NotificationModel.fromEntity(notification);
      final doc = await _notifications.add(model.toMap());
      return model.copyWith(id: doc.id);
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'save this notification'));
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotificationsForUser(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(NotificationModel.fromFirestore).toList());
  }

  @override
  Future<bool> existsByEventKey({
    required String userId,
    required String eventKey,
  }) async {
    try {
      final snapshot = await _notifications
          .where('userId', isEqualTo: userId)
          .where('eventKey', isEqualTo: eventKey)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'check notifications'));
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'mark this notification as read'));
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notifications
          .where('userId', isEqualTo: userId)
          .where('readAt', isNull: true)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'readAt': now});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'mark notifications as read'));
    }
  }

  String _mapFirestoreError(FirebaseException e, String action) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to $action.';
      case 'unavailable':
        return 'No connection to the server. Check your internet and try again.';
      case 'failed-precondition':
        return 'The database is missing an index for this query. '
            'Open the link in the console log to create it.';
      default:
        return e.message ?? 'Could not $action. Please try again.';
    }
  }
}
