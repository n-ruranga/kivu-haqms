import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivu_haqms/features/appointments/data/models/appointment_model.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';

void main() {
  final scheduledAt = DateTime(2026, 8, 3, 9, 30);
  final createdAt = DateTime(2026, 7, 28, 14, 0);

  Map<String, dynamic> validDocument() => {
        'patientId': 'patient-1',
        'patientName': 'Kethia U.',
        'departmentId': 'cardiology',
        'departmentName': 'Cardiology',
        'doctorId': 'doc-1',
        'doctorName': 'Dr. Eric Nsengimana',
        'specialty': 'Cardiology Specialist',
        'hospital': 'Kigali Central Hospital',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'timeSlot': '09:30',
        'status': 'confirmed',
        'createdAt': Timestamp.fromDate(createdAt),
        'reason': 'Chest pain',
        'queueNumber': 4,
        'updatedAt': null,
      };

  group('AppointmentModel.fromMap', () {
    test('maps every field, including Timestamps and the status name', () {
      final model =
          AppointmentModel.fromMap('appointment-123', validDocument());

      expect(model.id, 'appointment-123');
      expect(model.patientId, 'patient-1');
      expect(model.doctorName, 'Dr. Eric Nsengimana');
      expect(model.scheduledAt, scheduledAt);
      expect(model.createdAt, createdAt);
      expect(model.timeSlot, '09:30');
      expect(model.status, AppointmentStatus.confirmed);
      expect(model.reason, 'Chest pain');
      expect(model.queueNumber, 4);
      expect(model.updatedAt, isNull);
    });

    test('falls back to pending for an unknown or missing status', () {
      final unknown = AppointmentModel.fromMap(
        'a1',
        {...validDocument(), 'status': 'not-a-status'},
      );
      final missing = AppointmentModel.fromMap(
        'a2',
        {...validDocument()}..remove('status'),
      );

      expect(unknown.status, AppointmentStatus.pending);
      expect(missing.status, AppointmentStatus.pending);
    });

    test('does not throw on a document with no data', () {
      final model = AppointmentModel.fromMap('a3', null);

      expect(model.id, 'a3');
      expect(model.patientId, isEmpty);
      expect(model.status, AppointmentStatus.pending);
    });
  });

  group('AppointmentModel.toMap', () {
    test('round-trips back into an identical entity', () {
      final original =
          AppointmentModel.fromMap('appointment-123', validDocument());

      final roundTripped =
          AppointmentModel.fromMap('appointment-123', original.toMap());

      expect(roundTripped, equals(original));
    });

    test('writes the status as its name, never its index', () {
      final map = AppointmentModel.fromMap('a1', validDocument()).toMap();

      expect(map['status'], 'confirmed');
      expect(map['scheduledAt'], isA<Timestamp>());
      // The document id lives on the document, not inside it.
      expect(map.containsKey('id'), isFalse);
    });
  });

  group('AppointmentEntity rules', () {
    AppointmentEntity appointmentWith({
      required DateTime scheduledAt,
      required AppointmentStatus status,
    }) {
      return AppointmentEntity(
        id: 'a1',
        patientId: 'patient-1',
        patientName: 'Kethia U.',
        departmentId: 'cardiology',
        departmentName: 'Cardiology',
        doctorId: 'doc-1',
        doctorName: 'Dr. Eric Nsengimana',
        specialty: 'Cardiology Specialist',
        hospital: 'Kigali Central Hospital',
        scheduledAt: scheduledAt,
        timeSlot: '09:30',
        status: status,
        createdAt: DateTime.now(),
      );
    }

    final future = DateTime.now().add(const Duration(days: 2));
    final past = DateTime.now().subtract(const Duration(days: 2));

    test('a future pending or confirmed appointment can be modified', () {
      expect(
        appointmentWith(
          scheduledAt: future,
          status: AppointmentStatus.pending,
        ).canBeModified,
        isTrue,
      );
      expect(
        appointmentWith(
          scheduledAt: future,
          status: AppointmentStatus.confirmed,
        ).canBeModified,
        isTrue,
      );
    });

    test('cancelled, completed or past appointments cannot be modified', () {
      expect(
        appointmentWith(
          scheduledAt: future,
          status: AppointmentStatus.cancelled,
        ).canBeModified,
        isFalse,
      );
      expect(
        appointmentWith(
          scheduledAt: future,
          status: AppointmentStatus.completed,
        ).canBeModified,
        isFalse,
      );
      expect(
        appointmentWith(
          scheduledAt: past,
          status: AppointmentStatus.confirmed,
        ).canBeModified,
        isFalse,
      );
    });

    test('copyWith changes the status and keeps everything else', () {
      final original = appointmentWith(
        scheduledAt: future,
        status: AppointmentStatus.pending,
      );

      final cancelled = original.copyWith(status: AppointmentStatus.cancelled);

      expect(cancelled.status, AppointmentStatus.cancelled);
      expect(cancelled.doctorId, original.doctorId);
      expect(cancelled.scheduledAt, original.scheduledAt);
      expect(cancelled.createdAt, original.createdAt);
    });
  });
}
