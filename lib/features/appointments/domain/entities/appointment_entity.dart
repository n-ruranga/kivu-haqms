import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';

/// A booking made by a patient with one doctor at one point in time.
///
/// Department and doctor names are denormalised onto the document on purpose:
/// the schedule list renders from a single query with no extra reads, and the
/// appointment keeps the details that were true on the day it was booked.
class AppointmentEntity extends Equatable {
  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.departmentId,
    required this.departmentName,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.scheduledAt,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.reason,
    this.queueNumber,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String departmentId;
  final String departmentName;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String hospital;

  /// Date and start time of the slot, in the device's local time zone.
  final DateTime scheduledAt;

  /// The `HH:mm` slot label the patient picked, kept for display.
  final String timeSlot;

  final AppointmentStatus status;
  final DateTime createdAt;
  final String? reason;
  final int? queueNumber;
  final DateTime? updatedAt;

  bool get isUpcoming =>
      status.isActive && scheduledAt.isAfter(DateTime.now());

  /// Guards the Cancel / Reschedule actions in the UI.
  bool get canBeModified => isUpcoming;

  AppointmentEntity copyWith({
    String? id,
    AppointmentStatus? status,
    DateTime? scheduledAt,
    String? timeSlot,
    String? reason,
    int? queueNumber,
    DateTime? updatedAt,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      patientId: patientId,
      patientName: patientName,
      departmentId: departmentId,
      departmentName: departmentName,
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      hospital: hospital,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      createdAt: createdAt,
      reason: reason ?? this.reason,
      queueNumber: queueNumber ?? this.queueNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        departmentId,
        departmentName,
        doctorId,
        doctorName,
        specialty,
        hospital,
        scheduledAt,
        timeSlot,
        status,
        createdAt,
        reason,
        queueNumber,
        updatedAt,
      ];
}
