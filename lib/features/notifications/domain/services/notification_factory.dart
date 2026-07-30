import 'package:kivu_haqms/core/utils/date_format.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_type.dart';

/// Builds notification payloads for appointment-related events.
abstract final class NotificationFactory {
  static NotificationEntity bookingReceived({
    required String userId,
    required AppointmentEntity appointment,
  }) {
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.bookingReceived,
      title: 'Appointment requested',
      body:
          'Your request with ${appointment.doctorName} on '
          '${AppDateFormat.relativeDateTime(appointment.scheduledAt, appointment.timeSlot)} '
          'has been sent to the hospital.',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey: 'booking_${appointment.id}',
    );
  }

  static NotificationEntity appointmentConfirmed({
    required String userId,
    required AppointmentEntity appointment,
  }) {
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.appointmentConfirmed,
      title: 'Appointment confirmed',
      body:
          '${appointment.doctorName} confirmed your visit on '
          '${AppDateFormat.relativeDateTime(appointment.scheduledAt, appointment.timeSlot)}.',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey: 'confirmed_${appointment.id}',
    );
  }

  static NotificationEntity appointmentCancelled({
    required String userId,
    required AppointmentEntity appointment,
  }) {
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.appointmentCancelled,
      title: 'Appointment cancelled',
      body:
          'Your appointment with ${appointment.doctorName} on '
          '${AppDateFormat.relativeDateTime(appointment.scheduledAt, appointment.timeSlot)} '
          'has been cancelled.',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey: 'cancelled_${appointment.id}',
    );
  }

  static NotificationEntity appointmentRescheduled({
    required String userId,
    required AppointmentEntity appointment,
  }) {
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.appointmentRescheduled,
      title: 'Appointment rescheduled',
      body:
          'Your visit with ${appointment.doctorName} is now '
          '${AppDateFormat.relativeDateTime(appointment.scheduledAt, appointment.timeSlot)}. '
          'Waiting for hospital confirmation.',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey:
          'rescheduled_${appointment.id}_${appointment.scheduledAt.millisecondsSinceEpoch}',
    );
  }

  static NotificationEntity appointmentCompleted({
    required String userId,
    required AppointmentEntity appointment,
  }) {
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.appointmentCompleted,
      title: 'Visit completed',
      body:
          'Your appointment with ${appointment.doctorName} has been marked as completed. '
          'We hope you feel better soon.',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey: 'completed_${appointment.id}',
    );
  }

  static NotificationEntity appointmentReminder({
    required String userId,
    required AppointmentEntity appointment,
    required Duration leadTime,
  }) {
    final label = leadTime.inHours >= 24 ? '24 hours' : '1 hour';
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.appointmentReminder,
      title: 'Upcoming appointment',
      body:
          'Reminder: you have an appointment with ${appointment.doctorName} in $label '
          '(${AppDateFormat.relativeDateTime(appointment.scheduledAt, appointment.timeSlot)}).',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey: leadTime.inHours >= 24
          ? 'reminder_24h_${appointment.id}'
          : 'reminder_1h_${appointment.id}',
    );
  }

  static NotificationEntity queueAlmostReady({
    required String userId,
    required AppointmentEntity appointment,
    required int position,
  }) {
    return NotificationEntity(
      id: '',
      userId: userId,
      type: NotificationType.queueAlmostReady,
      title: 'Almost your turn',
      body: position <= 1
          ? 'You are next in line for ${appointment.doctorName}. Please head to the clinic.'
          : 'Only $position people ahead of you for ${appointment.doctorName}.',
      createdAt: DateTime.now(),
      appointmentId: appointment.id,
      eventKey: 'queue_ready_${appointment.id}',
    );
  }
}
