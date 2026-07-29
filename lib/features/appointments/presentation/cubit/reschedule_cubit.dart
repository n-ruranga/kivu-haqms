import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/reschedule_state.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';

/// UPDATE — moves an existing appointment to a different date and slot.
///
/// Loads the doctor fresh so the sheet always offers the doctor's current
/// working days rather than whatever was denormalised onto the appointment.
class RescheduleCubit extends Cubit<RescheduleState> {
  RescheduleCubit(
    this._appointment,
    this._doctorRepository,
    this._appointmentRepository,
  ) : super(const RescheduleState());

  final AppointmentEntity _appointment;
  final DoctorRepository _doctorRepository;
  final AppointmentRepository _appointmentRepository;

  Future<void> load() async {
    try {
      final doctor =
          await _doctorRepository.getDoctorById(_appointment.doctorId);

      if (doctor == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'That doctor is no longer available.',
        ));
        return;
      }

      emit(state.copyWith(isLoading: false, doctor: doctor));

      final firstDate = state.selectableDates.firstOrNull;
      if (firstDate != null) {
        await selectDate(firstDate);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _readableError(e),
      ));
    }
  }

  Future<void> selectDate(DateTime date) async {
    emit(state.copyWith(
      selectedDate: date,
      isLoadingSlots: true,
      bookedSlots: const [],
      clearSlot: true,
      clearError: true,
    ));

    try {
      final booked = await _appointmentRepository.getBookedSlots(
        doctorId: _appointment.doctorId,
        date: date,
      );

      // The appointment being moved should not block its own slot.
      final isSameDay = date.year == _appointment.scheduledAt.year &&
          date.month == _appointment.scheduledAt.month &&
          date.day == _appointment.scheduledAt.day;

      final filtered = isSameDay
          ? (List.of(booked)..remove(_appointment.timeSlot))
          : booked;

      emit(state.copyWith(bookedSlots: filtered, isLoadingSlots: false));
    } catch (e) {
      emit(state.copyWith(
        isLoadingSlots: false,
        errorMessage: _readableError(e),
      ));
    }
  }

  void selectSlot(String slot) {
    if (state.bookedSlots.contains(slot)) return;
    emit(state.copyWith(selectedSlot: slot, clearError: true));
  }

  Future<void> save() async {
    final date = state.selectedDate;
    final slot = state.selectedSlot;
    if (date == null || slot == null) return;

    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final parts = slot.split(':');
      final scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        int.tryParse(parts.first) ?? 0,
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );

      await _appointmentRepository.rescheduleAppointment(
        appointmentId: _appointment.id,
        scheduledAt: scheduledAt,
        timeSlot: slot,
      );

      emit(state.copyWith(isSaving: false, isDone: true));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: _readableError(e),
      ));
    }
  }

  String _readableError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
