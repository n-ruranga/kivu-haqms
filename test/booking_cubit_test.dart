import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/booking_cubit.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/booking_state.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';

class MockDoctorRepository extends Mock implements DoctorRepository {}

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockDoctorRepository doctorRepository;
  late MockAppointmentRepository appointmentRepository;

  const department = DepartmentEntity(
    id: 'cardiology',
    name: 'Cardiology',
    description: 'Heart care',
    iconKey: 'cardiology',
  );

  // Available every day of the week so `selectableDates` always starts today,
  // which keeps these tests independent of the day they run on.
  const doctor = DoctorEntity(
    id: 'doc-1',
    fullName: 'Dr. Eric Nsengimana',
    departmentId: 'cardiology',
    specialty: 'Cardiology Specialist',
    hospital: 'Kigali Central Hospital',
    availableDays: [1, 2, 3, 4, 5, 6, 7],
    availableSlots: ['08:00', '08:30', '09:00'],
  );

  setUpAll(() {
    registerFallbackValue(
      AppointmentEntity(
        id: '',
        patientId: '',
        patientName: '',
        departmentId: '',
        departmentName: '',
        doctorId: '',
        doctorName: '',
        specialty: '',
        hospital: '',
        scheduledAt: DateTime(2026),
        timeSlot: '08:00',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    doctorRepository = MockDoctorRepository();
    appointmentRepository = MockAppointmentRepository();

    when(() => doctorRepository.getDepartments())
        .thenAnswer((_) async => [department]);
    when(() => doctorRepository.getDoctorsByDepartment(any()))
        .thenAnswer((_) async => [doctor]);
    when(() => appointmentRepository.getBookedSlots(
          doctorId: any(named: 'doctorId'),
          date: any(named: 'date'),
        )).thenAnswer((_) async => <String>[]);
  });

  BookingCubit buildCubit() =>
      BookingCubit(doctorRepository, appointmentRepository);

  /// Walks the form through department -> doctor -> date -> slot.
  Future<void> completeForm(BookingCubit cubit, {String slot = '08:30'}) async {
    await cubit.loadDepartments();
    await cubit.selectDepartment(department);
    await cubit.selectDoctor(doctor);
    cubit.selectSlot(slot);
  }

  group('BookingCubit — loading reference data', () {
    blocTest<BookingCubit, BookingState>(
      'emits [loading, ready] with the departments from the repository',
      build: buildCubit,
      act: (cubit) => cubit.loadDepartments(),
      expect: () => [
        const BookingState(status: BookingStatus.loading),
        const BookingState(
          status: BookingStatus.ready,
          departments: [department],
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'emits failure with a readable message when departments cannot load',
      setUp: () {
        when(() => doctorRepository.getDepartments())
            .thenThrow(Exception('No connection to the server.'));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadDepartments(),
      verify: (cubit) {
        expect(cubit.state.status, BookingStatus.failure);
        expect(cubit.state.errorMessage, 'No connection to the server.');
      },
    );

    blocTest<BookingCubit, BookingState>(
      'selecting a department loads that department\'s doctors',
      build: buildCubit,
      act: (cubit) => cubit.selectDepartment(department),
      verify: (cubit) {
        expect(cubit.state.selectedDepartment, department);
        expect(cubit.state.doctors, [doctor]);
        expect(cubit.state.isLoadingDoctors, isFalse);
        verify(() => doctorRepository.getDoctorsByDepartment('cardiology'))
            .called(1);
      },
    );
  });

  group('BookingCubit — dependent selections', () {
    blocTest<BookingCubit, BookingState>(
      'selecting a doctor auto-picks the first working day and loads its slots',
      build: buildCubit,
      act: (cubit) async {
        await cubit.selectDepartment(department);
        await cubit.selectDoctor(doctor);
      },
      verify: (cubit) {
        expect(cubit.state.selectedDoctor, doctor);
        expect(cubit.state.selectedDate, isNotNull);
        expect(cubit.state.isLoadingSlots, isFalse);
        verify(() => appointmentRepository.getBookedSlots(
              doctorId: 'doc-1',
              date: any(named: 'date'),
            )).called(1);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'changing department clears the doctor, date and slot',
      build: buildCubit,
      act: (cubit) async {
        await completeForm(cubit);
        await cubit.selectDepartment(
          const DepartmentEntity(
            id: 'general',
            name: 'General Medicine',
            description: 'Check-ups',
            iconKey: 'general',
          ),
        );
      },
      verify: (cubit) {
        expect(cubit.state.selectedDoctor, isNull);
        expect(cubit.state.selectedDate, isNull);
        expect(cubit.state.selectedSlot, isNull);
        expect(cubit.state.canSubmit, isFalse);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'a slot that is already booked cannot be selected',
      setUp: () {
        when(() => appointmentRepository.getBookedSlots(
              doctorId: any(named: 'doctorId'),
              date: any(named: 'date'),
            )).thenAnswer((_) async => ['08:30']);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.selectDepartment(department);
        await cubit.selectDoctor(doctor);
        cubit.selectSlot('08:30');
      },
      verify: (cubit) {
        expect(cubit.state.bookedSlots, ['08:30']);
        expect(cubit.state.selectedSlot, isNull);
      },
    );
  });

  group('BookingCubit — creating the appointment', () {
    blocTest<BookingCubit, BookingState>(
      'writes the appointment and emits success with the stored id',
      setUp: () {
        when(() => appointmentRepository.createAppointment(any())).thenAnswer(
          (invocation) async =>
              (invocation.positionalArguments.first as AppointmentEntity)
                  .copyWith(id: 'appointment-123'),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        await completeForm(cubit);
        cubit.updateReason('  Chest pain  ');
        await cubit.submitBooking(
          patientId: 'patient-1',
          patientName: 'Kethia U.',
        );
      },
      verify: (cubit) {
        final created = cubit.state.createdAppointment;

        expect(cubit.state.status, BookingStatus.success);
        expect(created?.id, 'appointment-123');
        expect(created?.patientId, 'patient-1');
        expect(created?.doctorId, 'doc-1');
        expect(created?.departmentName, 'Cardiology');
        expect(created?.timeSlot, '08:30');
        expect(created?.status, AppointmentStatus.pending);
        // The reason is trimmed before it reaches Firestore.
        expect(created?.reason, 'Chest pain');
        // Date and slot are merged into one timestamp.
        expect(created?.scheduledAt.hour, 8);
        expect(created?.scheduledAt.minute, 30);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'refuses to submit while a step is still missing',
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadDepartments();
        await cubit.submitBooking(
          patientId: 'patient-1',
          patientName: 'Kethia U.',
        );
      },
      verify: (cubit) {
        expect(cubit.state.status, BookingStatus.failure);
        expect(
          cubit.state.errorMessage,
          'Please complete every step before confirming.',
        );
        verifyNever(() => appointmentRepository.createAppointment(any()));
      },
    );

    blocTest<BookingCubit, BookingState>(
      'surfaces a taken slot as a failure instead of crashing',
      setUp: () {
        when(() => appointmentRepository.createAppointment(any())).thenThrow(
          Exception('That slot has just been taken. Please pick another time.'),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        await completeForm(cubit);
        await cubit.submitBooking(
          patientId: 'patient-1',
          patientName: 'Kethia U.',
        );
      },
      verify: (cubit) {
        expect(cubit.state.status, BookingStatus.failure);
        expect(
          cubit.state.errorMessage,
          'That slot has just been taken. Please pick another time.',
        );
        expect(cubit.state.createdAppointment, isNull);
      },
    );
  });
}
