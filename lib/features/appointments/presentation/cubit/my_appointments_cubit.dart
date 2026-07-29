import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/my_appointments_state.dart';

/// READ + UPDATE side of appointment CRUD.
///
/// Subscribes to the patient's appointments so a status change written from
/// anywhere (this app, another device, or the hospital's console) shows up
/// without a manual refresh.
class MyAppointmentsCubit extends Cubit<MyAppointmentsState> {
  MyAppointmentsCubit(this._repository) : super(const MyAppointmentsState());

  final AppointmentRepository _repository;
  StreamSubscription<List<AppointmentEntity>>? _subscription;

  void watchAppointments(String patientId) {
    emit(state.copyWith(status: MyAppointmentsStatus.loading, clearError: true));

    _subscription?.cancel();
    _subscription = _repository.watchAppointmentsForPatient(patientId).listen(
      (appointments) {
        emit(state.copyWith(
          status: MyAppointmentsStatus.loaded,
          appointments: appointments,
          clearBusy: true,
        ));
      },
      onError: (Object error) {
        emit(state.copyWith(
          status: MyAppointmentsStatus.failure,
          errorMessage: _readableError(error),
          clearBusy: true,
        ));
      },
    );
  }

  Future<void> cancelAppointment(String appointmentId) =>
      _changeStatus(appointmentId, AppointmentStatus.cancelled);

  Future<void> confirmAppointment(String appointmentId) =>
      _changeStatus(appointmentId, AppointmentStatus.confirmed);

  Future<void> completeAppointment(String appointmentId) =>
      _changeStatus(appointmentId, AppointmentStatus.completed);

  Future<void> _changeStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    emit(state.copyWith(busyAppointmentId: appointmentId, clearError: true));
    try {
      await _repository.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
      );
      // The stream pushes the new list, which clears the busy flag.
    } catch (e) {
      emit(state.copyWith(
        errorMessage: _readableError(e),
        clearBusy: true,
      ));
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    emit(state.copyWith(busyAppointmentId: appointmentId, clearError: true));
    try {
      await _repository.deleteAppointment(appointmentId);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: _readableError(e),
        clearBusy: true,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  String _readableError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
