import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';

enum MyAppointmentsStatus { initial, loading, loaded, failure }

class MyAppointmentsState extends Equatable {
  const MyAppointmentsState({
    this.status = MyAppointmentsStatus.initial,
    this.appointments = const [],
    this.busyAppointmentId,
    this.errorMessage,
  });

  final MyAppointmentsStatus status;
  final List<AppointmentEntity> appointments;

  /// Id of the appointment currently being updated, so only that card shows a
  /// spinner instead of the whole list.
  final String? busyAppointmentId;

  final String? errorMessage;

  List<AppointmentEntity> get upcoming =>
      appointments.where((a) => a.isUpcoming).toList().reversed.toList();

  List<AppointmentEntity> get past =>
      appointments.where((a) => !a.isUpcoming).toList();

  bool get isEmpty =>
      status == MyAppointmentsStatus.loaded && appointments.isEmpty;

  MyAppointmentsState copyWith({
    MyAppointmentsStatus? status,
    List<AppointmentEntity>? appointments,
    String? busyAppointmentId,
    String? errorMessage,
    bool clearBusy = false,
    bool clearError = false,
  }) {
    return MyAppointmentsState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      busyAppointmentId:
          clearBusy ? null : busyAppointmentId ?? this.busyAppointmentId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, appointments, busyAppointmentId, errorMessage];
}
