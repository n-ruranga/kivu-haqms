import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kivu_haqms/features/notifications/domain/services/notification_factory.dart';
import 'package:kivu_haqms/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:kivu_haqms/features/profile/domain/repositories/profile_repository.dart';

/// Manages the patient's notification inbox and watches appointment changes
/// to create notifications for booking, status updates, reminders, and queue
/// alerts.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._notificationRepository,
    this._appointmentRepository,
    this._profileRepository,
    this._authRepository,
  ) : super(const NotificationsState()) {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        startWatching(user.id);
      } else {
        stopWatching();
      }
    });
  }

  final NotificationRepository _notificationRepository;
  final AppointmentRepository _appointmentRepository;
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  StreamSubscription<List<NotificationEntity>>? _notificationsSubscription;
  StreamSubscription<List<AppointmentEntity>>? _appointmentsSubscription;
  final Map<String, StreamSubscription<List<AppointmentEntity>>>
      _queueSubscriptions = {};
  Timer? _reminderTimer;

  StreamSubscription<UserEntity?>? _authSubscription;

  String? _userId;
  bool _appointmentsInitialized = false;
  final Map<String, _TrackedAppointment> _trackedAppointments = {};
  final Set<String> _queueNotified = {};

  Future<void> startWatching(String userId) async {
    if (_userId == userId && _notificationsSubscription != null) return;

    stopWatching();
    _userId = userId;
    _appointmentsInitialized = false;
    _trackedAppointments.clear();
    _queueNotified.clear();

    emit(state.copyWith(status: NotificationsStatus.loading, clearError: true));

    _notificationsSubscription = _notificationRepository
        .watchNotificationsForUser(userId)
        .listen(
      (notifications) {
        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: notifications,
        ));
      },
      onError: (Object error) {
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: _readableError(error),
        ));
      },
    );

    _appointmentsSubscription = _appointmentRepository
        .watchAppointmentsForPatient(userId)
        .listen(
      (appointments) {
        unawaited(_onAppointmentsChanged(userId, appointments));
      },
      onError: (_) {},
    );

    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_checkReminders(userId)),
    );
    unawaited(_checkReminders(userId));
  }

  void stopWatching() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = null;
    _reminderTimer?.cancel();
    _reminderTimer = null;

    for (final subscription in _queueSubscriptions.values) {
      subscription.cancel();
    }
    _queueSubscriptions.clear();

    _userId = null;
    _appointmentsInitialized = false;
    _trackedAppointments.clear();
    _queueNotified.clear();
    emit(const NotificationsState());
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (e) {
      emit(state.copyWith(errorMessage: _readableError(e)));
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _notificationRepository.markAllAsRead(userId);
    } catch (e) {
      emit(state.copyWith(errorMessage: _readableError(e)));
    }
  }

  Future<void> _onAppointmentsChanged(
    String userId,
    List<AppointmentEntity> appointments,
  ) async {
    if (!_appointmentsInitialized) {
      for (final appointment in appointments) {
        _trackedAppointments[appointment.id] = _TrackedAppointment(
          status: appointment.status,
          scheduledAt: appointment.scheduledAt,
          timeSlot: appointment.timeSlot,
        );
        _watchQueueIfNeeded(userId, appointment);
      }
      _appointmentsInitialized = true;
      return;
    }

    final currentIds = appointments.map((a) => a.id).toSet();

    for (final appointment in appointments) {
      final previous = _trackedAppointments[appointment.id];

      if (previous == null) {
        await _createIfNew(
          NotificationFactory.bookingReceived(
            userId: userId,
            appointment: appointment,
          ),
        );
      } else {
        if (previous.status != appointment.status) {
          await _notifyStatusChange(userId, appointment, previous.status);
        } else if (previous.scheduledAt != appointment.scheduledAt ||
            previous.timeSlot != appointment.timeSlot) {
          await _createIfNew(
            NotificationFactory.appointmentRescheduled(
              userId: userId,
              appointment: appointment,
            ),
          );
        }
      }

      _trackedAppointments[appointment.id] = _TrackedAppointment(
        status: appointment.status,
        scheduledAt: appointment.scheduledAt,
        timeSlot: appointment.timeSlot,
      );
      _watchQueueIfNeeded(userId, appointment);
    }

    _trackedAppointments.removeWhere((id, _) => !currentIds.contains(id));
    _queueSubscriptions.removeWhere((id, subscription) {
      if (!currentIds.contains(id)) {
        subscription.cancel();
        _queueNotified.remove(id);
        return true;
      }
      return false;
    });
  }

  Future<void> _notifyStatusChange(
    String userId,
    AppointmentEntity appointment,
    AppointmentStatus previousStatus,
  ) async {
    final notification = switch (appointment.status) {
      AppointmentStatus.confirmed => NotificationFactory.appointmentConfirmed(
          userId: userId,
          appointment: appointment,
        ),
      AppointmentStatus.cancelled => NotificationFactory.appointmentCancelled(
          userId: userId,
          appointment: appointment,
        ),
      AppointmentStatus.completed => NotificationFactory.appointmentCompleted(
          userId: userId,
          appointment: appointment,
        ),
      AppointmentStatus.pending when previousStatus == AppointmentStatus.confirmed =>
        NotificationFactory.appointmentRescheduled(
          userId: userId,
          appointment: appointment,
        ),
      _ => null,
    };

    if (notification != null) {
      await _createIfNew(notification);
    }
  }

  void _watchQueueIfNeeded(String userId, AppointmentEntity appointment) {
    if (!appointment.status.isActive || !_isToday(appointment.scheduledAt)) {
      _queueSubscriptions.remove(appointment.id)?.cancel();
      return;
    }

    if (_queueSubscriptions.containsKey(appointment.id)) return;

    _queueSubscriptions[appointment.id] = _appointmentRepository
        .watchAppointmentsForDoctorOnDate(
      doctorId: appointment.doctorId,
      date: appointment.scheduledAt,
    )
        .listen((doctorAppointments) {
      unawaited(
        _checkQueuePosition(userId, appointment, doctorAppointments),
      );
    });
  }

  Future<void> _checkQueuePosition(
    String userId,
    AppointmentEntity appointment,
    List<AppointmentEntity> doctorAppointments,
  ) async {
    if (_queueNotified.contains(appointment.id)) return;
    if (!appointment.status.isActive) return;

    final ticket = appointment.queueNumber;
    if (ticket == null) return;

    final completedAhead = doctorAppointments
        .where((a) =>
            a.status == AppointmentStatus.completed &&
            (a.queueNumber ?? 0) < ticket)
        .length;

    final position = ticket - completedAhead;
    if (position > 2) return;

    _queueNotified.add(appointment.id);
    await _createIfNew(
      NotificationFactory.queueAlmostReady(
        userId: userId,
        appointment: appointment,
        position: position < 1 ? 1 : position,
      ),
    );
  }

  Future<void> _checkReminders(String userId) async {
    try {
      final authUser = await _authRepository.getCurrentUser();
      if (authUser == null || authUser.id != userId) return;

      final profile = await _profileRepository.getProfile(authUser);
      if (!profile.appointmentRemindersEnabled) return;

      final appointments =
          await _appointmentRepository.getAppointmentsForPatient(userId);
      final now = DateTime.now();

      for (final appointment in appointments) {
        if (appointment.status != AppointmentStatus.confirmed) continue;
        if (!appointment.scheduledAt.isAfter(now)) continue;

        final timeUntil = appointment.scheduledAt.difference(now);

        if (timeUntil <= const Duration(hours: 24) &&
            timeUntil > const Duration(hours: 23)) {
          await _createIfNew(
            NotificationFactory.appointmentReminder(
              userId: userId,
              appointment: appointment,
              leadTime: const Duration(hours: 24),
            ),
          );
        }

        if (timeUntil <= const Duration(hours: 1) &&
            timeUntil > const Duration(minutes: 55)) {
          await _createIfNew(
            NotificationFactory.appointmentReminder(
              userId: userId,
              appointment: appointment,
              leadTime: const Duration(hours: 1),
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _createIfNew(NotificationEntity notification) async {
    try {
      await _notificationRepository.createNotification(notification);
    } catch (_) {}
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _readableError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    stopWatching();
    return super.close();
  }
}

class _TrackedAppointment {
  const _TrackedAppointment({
    required this.status,
    required this.scheduledAt,
    required this.timeSlot,
  });

  final AppointmentStatus status;
  final DateTime scheduledAt;
  final String timeSlot;
}
