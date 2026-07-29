import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';

/// Firestore <-> domain mapping for an `appointments/{appointmentId}` document.
class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.departmentId,
    required super.departmentName,
    required super.doctorId,
    required super.doctorName,
    required super.specialty,
    required super.hospital,
    required super.scheduledAt,
    required super.timeSlot,
    required super.status,
    required super.createdAt,
    super.reason,
    super.queueNumber,
    super.updatedAt,
  });

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AppointmentModel.fromMap(doc.id, doc.data());
  }

  /// The real mapping. Kept separate from [fromFirestore] so it can be unit
  /// tested with a plain map — `DocumentSnapshot` is sealed and cannot be
  /// mocked.
  factory AppointmentModel.fromMap(String id, Map<String, dynamic>? raw) {
    final data = raw ?? const <String, dynamic>{};

    return AppointmentModel(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      departmentName: data['departmentName'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      hospital: data['hospital'] as String? ?? '',
      scheduledAt: _toDateTime(data['scheduledAt']) ?? DateTime.now(),
      timeSlot: data['timeSlot'] as String? ?? '',
      status: AppointmentStatus.fromName(data['status'] as String?),
      createdAt: _toDateTime(data['createdAt']) ?? DateTime.now(),
      reason: data['reason'] as String?,
      queueNumber: (data['queueNumber'] as num?)?.toInt(),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      departmentId: entity.departmentId,
      departmentName: entity.departmentName,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      specialty: entity.specialty,
      hospital: entity.hospital,
      scheduledAt: entity.scheduledAt,
      timeSlot: entity.timeSlot,
      status: entity.status,
      createdAt: entity.createdAt,
      reason: entity.reason,
      queueNumber: entity.queueNumber,
      updatedAt: entity.updatedAt,
    );
  }

  /// Payload for `set()`. The document id is never duplicated inside the
  /// document — it comes from `doc.id` on the way back out.
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'hospital': hospital,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'timeSlot': timeSlot,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'reason': reason,
      'queueNumber': queueNumber,
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  static DateTime? _toDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
