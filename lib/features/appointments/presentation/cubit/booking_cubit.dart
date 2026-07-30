import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/booking_state.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';

/// Drives the four-step booking form: department -> doctor -> date -> time.
///
/// Each selection invalidates the ones after it, so picking a new department
/// clears the chosen doctor, date and slot.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._doctorRepository, this._appointmentRepository)
      : super(const BookingState());

  final DoctorRepository _doctorRepository;
  final AppointmentRepository _appointmentRepository;

  Future<void> loadDepartments() async {
    emit(state.copyWith(status: BookingStatus.loading, clearError: true));
    try {
      final departments = await _doctorRepository.getDepartments();
      emit(state.copyWith(
        status: BookingStatus.ready,
        departments: departments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: _readableError(e),
      ));
    }
  }

  Future<void> selectDepartment(DepartmentEntity department) async {
    if (state.selectedDepartment?.id == department.id) return;

    emit(state.copyWith(
      selectedDepartment: department,
      doctors: const [],
      bookedSlots: const [],
      isLoadingDoctors: true,
      clearDoctor: true,
      clearDate: true,
      clearSlot: true,
      clearError: true,
    ));

    try {
      final doctors =
          await _doctorRepository.getDoctorsByDepartment(department.id);
      emit(state.copyWith(doctors: doctors, isLoadingDoctors: false));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDoctors: false,
        status: BookingStatus.failure,
        errorMessage: _readableError(e),
      ));
    }
  }

  Future<void> selectDoctor(DoctorEntity doctor) async {
    emit(state.copyWith(
      selectedDoctor: doctor,
      bookedSlots: const [],
      clearDate: true,
      clearSlot: true,
      clearError: true,
    ));

    // Jump straight to the doctor's next working day so the slot grid is never
    // empty when it first appears.
    final firstDate = state.selectableDates.firstOrNull;
    if (firstDate != null) {
      await selectDate(firstDate);
    }
  }

  Future<void> selectDate(DateTime date) async {
    final doctor = state.selectedDoctor;
    if (doctor == null) return;

    emit(state.copyWith(
      selectedDate: date,
      isLoadingSlots: true,
      bookedSlots: const [],
      clearSlot: true,
      clearError: true,
    ));

    try {
      final booked = await _appointmentRepository.getBookedSlots(
        doctorId: doctor.id,
        date: date,
      );
      emit(state.copyWith(bookedSlots: booked, isLoadingSlots: false));
    } catch (e) {
      emit(state.copyWith(
        isLoadingSlots: false,
        status: BookingStatus.failure,
        errorMessage: _readableError(e),
      ));
    }
  }

  void selectSlot(String slot) {
    if (state.isSlotBooked(slot)) return;
    emit(state.copyWith(selectedSlot: slot, clearError: true));
  }

  void updateReason(String reason) => emit(state.copyWith(reason: reason));

  /// CREATE — writes the appointment to Firestore for the signed-in patient.
  Future<void> submitBooking({
    required String patientId,
    required String patientName,
  }) async {
    final department = state.selectedDepartment;
    final doctor = state.selectedDoctor;
    final date = state.selectedDate;
    final slot = state.selectedSlot;

    if (department == null || doctor == null || date == null || slot == null) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Please complete every step before confirming.',
      ));
      return;
    }

    emit(state.copyWith(status: BookingStatus.submitting, clearError: true));

    try {
      final appointment = AppointmentEntity(
        id: '',
        patientId: patientId,
        patientName: patientName,
        departmentId: department.id,
        departmentName: department.name,
        doctorId: doctor.id,
        doctorName: doctor.fullName,
        specialty: doctor.specialty,
        hospital: doctor.hospital,
        scheduledAt: _combine(date, slot),
        timeSlot: slot,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
        reason: state.reason.trim().isEmpty ? null : state.reason.trim(),
      );

      final created =
          await _appointmentRepository.createAppointment(appointment);

      emit(state.copyWith(
        status: BookingStatus.success,
        createdAppointment: created,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: _readableError(e),
      ));
    }
  }

  /// Drops the form back to a clean slate, keeping the loaded departments.
  void reset() {
    emit(BookingState(
      status: BookingStatus.ready,
      departments: state.departments,
    ));
  }

  /// Merges a `yyyy-MM-dd` date with an `HH:mm` slot into one timestamp.
  static DateTime _combine(DateTime date, String slot) {
    final parts = slot.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.tryParse(parts.first) ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _readableError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
