import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';

/// Full CRUD contract for the `appointments` collection.
///
/// The presentation layer only ever talks to this interface, so the Firestore
/// implementation can be swapped for a fake in tests.
abstract interface class AppointmentRepository {
  /// CREATE — books a slot and returns the stored appointment with its new id.
  ///
  /// Throws if the slot was taken between loading the form and submitting it.
  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment);

  /// READ — one-shot fetch of a patient's appointments, newest first.
  Future<List<AppointmentEntity>> getAppointmentsForPatient(String patientId);

  /// READ — live stream of a patient's appointments for the schedule screen.
  Stream<List<AppointmentEntity>> watchAppointmentsForPatient(String patientId);

  /// READ — a single appointment, or `null` if it was deleted.
  Future<AppointmentEntity?> getAppointmentById(String appointmentId);

  /// READ — `HH:mm` slots already taken for [doctorId] on [date], so the
  /// booking form can grey them out.
  Future<List<String>> getBookedSlots({
    required String doctorId,
    required DateTime date,
  });

  /// UPDATE — moves an appointment through its lifecycle
  /// (pending → confirmed → completed, or → cancelled).
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
  });

  /// UPDATE — moves an existing appointment to a new date and slot.
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime scheduledAt,
    required String timeSlot,
  });

  /// DELETE — removes the record entirely. Cancelling is preferred so the
  /// hospital keeps an audit trail; this exists for the patient's "remove
  /// from history" action.
  Future<void> deleteAppointment(String appointmentId);
}
