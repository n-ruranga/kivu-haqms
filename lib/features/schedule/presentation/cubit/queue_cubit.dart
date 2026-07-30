import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/schedule/presentation/cubit/queue_state.dart';

/// Watches every appointment booked with one doctor on one day, so the
/// tracked patient's position updates live as others are seen.
class QueueCubit extends Cubit<QueueState> {
  QueueCubit(this._repository) : super(const QueueState());

  final AppointmentRepository _repository;
  StreamSubscription<List<AppointmentEntity>>? _subscription;

  void track(AppointmentEntity appointment) {
    emit(state.copyWith(
      status: QueueStatus.loading,
      appointment: appointment,
      clearError: true,
    ));

    _subscription?.cancel();
    _subscription = _repository
        .watchAppointmentsForDoctorOnDate(
      doctorId: appointment.doctorId,
      date: appointment.scheduledAt,
    )
        .listen(
      (appointments) {
        emit(state.copyWith(
          status: QueueStatus.loaded,
          doctorAppointmentsToday: appointments,
        ));
      },
      onError: (Object error) {
        emit(state.copyWith(
          status: QueueStatus.failure,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
