import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kivu_haqms/core/constants/firebase_constants.dart';
import 'package:kivu_haqms/features/appointments/data/models/appointment_model.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';

/// Cloud Firestore implementation of the appointment CRUD contract.
class FirestoreAppointmentRepository implements AppointmentRepository {
  FirestoreAppointmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection(FirebaseConstants.appointmentsCollection);

  // ---------------------------------------------------------------- CREATE

  @override
  Future<AppointmentEntity> createAppointment(
    AppointmentEntity appointment,
  ) async {
    try {
      final taken = await getBookedSlots(
        doctorId: appointment.doctorId,
        date: appointment.scheduledAt,
      );

      if (taken.contains(appointment.timeSlot)) {
        throw Exception(
          'That slot has just been taken. Please pick another time.',
        );
      }

      final model = AppointmentModel.fromEntity(appointment);
      final doc = await _appointments.add(model.toMap());

      return appointment.copyWith(id: doc.id);
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'book this appointment'));
    }
  }

  // ------------------------------------------------------------------ READ

  @override
  Future<List<AppointmentEntity>> getAppointmentsForPatient(
    String patientId,
  ) async {
    try {
      final snapshot = await _appointments
          .where('patientId', isEqualTo: patientId)
          .orderBy('scheduledAt', descending: true)
          .get();

      return snapshot.docs.map(AppointmentModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'load your appointments'));
    }
  }

  @override
  Stream<List<AppointmentEntity>> watchAppointmentsForPatient(
    String patientId,
  ) {
    return _appointments
        .where('patientId', isEqualTo: patientId)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AppointmentModel.fromFirestore).toList());
  }

  @override
  Future<AppointmentEntity?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _appointments.doc(appointmentId).get();
      if (!doc.exists) return null;
      return AppointmentModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'load that appointment'));
    }
  }

  @override
  Future<List<String>> getBookedSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _appointments
          .where('doctorId', isEqualTo: doctorId)
          .where('scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // Cancelled slots free up again, so they are filtered here rather than in
      // the query — that keeps this to one composite index.
      return snapshot.docs
          .map(AppointmentModel.fromFirestore)
          .where((appointment) => appointment.status.isActive)
          .map((appointment) => appointment.timeSlot)
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'check available times'));
    }
  }

  // ---------------------------------------------------------------- UPDATE

  @override
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) async {
    try {
      await _appointments.doc(appointmentId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'update this appointment'));
    }
  }

  @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime scheduledAt,
    required String timeSlot,
  }) async {
    try {
      await _appointments.doc(appointmentId).update({
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'timeSlot': timeSlot,
        'status': AppointmentStatus.pending.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'reschedule this appointment'));
    }
  }

  // ---------------------------------------------------------------- DELETE

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointments.doc(appointmentId).delete();
    } on FirebaseException catch (e) {
      throw Exception(_mapFirestoreError(e, 'delete this appointment'));
    }
  }

  String _mapFirestoreError(FirebaseException e, String action) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to $action.';
      case 'not-found':
        return 'That appointment no longer exists.';
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
