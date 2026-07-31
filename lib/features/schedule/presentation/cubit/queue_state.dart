import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';

enum QueueStatus { initial, loading, loaded, failure }

/// Live queue standing for one appointment, derived from every appointment
/// booked with the same doctor on the same day.
///
/// There is no separate "queue" collection — [AppointmentEntity.queueNumber]
/// is a same-day ticket number assigned at booking time, and position is
/// simply that ticket minus however many earlier tickets have been seen.
class QueueState extends Equatable {
  const QueueState({
    this.status = QueueStatus.initial,
    this.appointment,
    this.doctorAppointmentsToday = const [],
    this.errorMessage,
  });

  final QueueStatus status;
  final AppointmentEntity? appointment;

  /// Every appointment booked with this doctor for this date, all patients.
  final List<AppointmentEntity> doctorAppointmentsToday;
  final String? errorMessage;

  /// Roughly how long each consultation takes — matches the 30-minute
  /// cadence every doctor's seeded slot list uses.
  static const int slotDurationMinutes = 30;

  bool get isTrackable {
    final status = appointment?.status;
    return status == AppointmentStatus.pending ||
        status == AppointmentStatus.confirmed;
  }

  /// How many tickets ahead of this one have already been seen today.
  int get _completedAhead {
    final ticket = appointment?.queueNumber;
    if (ticket == null) return 0;

    return doctorAppointmentsToday
        .where((a) =>
            a.status == AppointmentStatus.completed &&
            (a.queueNumber ?? 0) < ticket)
        .length;
  }

  /// This patient's live spot in line, or `null` when there is nothing to
  /// track (no ticket number yet, or appointment isn't active).
  int? get position {
    final ticket = appointment?.queueNumber;
    if (ticket == null || !isTrackable) return null;

    final position = ticket - _completedAhead;
    return position < 1 ? 1 : position;
  }

  /// Active (pending/confirmed) tickets for this doctor today.
  int get totalInQueue =>
      doctorAppointmentsToday.where((a) => a.status.isActive).length;

  int? get estimatedWaitMinutes {
    final pos = position;
    if (pos == null) return null;
    return (pos - 1) * slotDurationMinutes;
  }

  QueueState copyWith({
    QueueStatus? status,
    AppointmentEntity? appointment,
    List<AppointmentEntity>? doctorAppointmentsToday,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QueueState(
      status: status ?? this.status,
      appointment: appointment ?? this.appointment,
      doctorAppointmentsToday:
          doctorAppointmentsToday ?? this.doctorAppointmentsToday,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, appointment, doctorAppointmentsToday, errorMessage];
}
