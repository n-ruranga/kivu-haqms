/// Categories of in-app notifications delivered to a patient.
enum NotificationType {
  bookingReceived,
  appointmentConfirmed,
  appointmentCancelled,
  appointmentRescheduled,
  appointmentCompleted,
  appointmentReminder,
  queueAlmostReady;

  String get name => switch (this) {
        NotificationType.bookingReceived => 'booking_received',
        NotificationType.appointmentConfirmed => 'appointment_confirmed',
        NotificationType.appointmentCancelled => 'appointment_cancelled',
        NotificationType.appointmentRescheduled => 'appointment_rescheduled',
        NotificationType.appointmentCompleted => 'appointment_completed',
        NotificationType.appointmentReminder => 'appointment_reminder',
        NotificationType.queueAlmostReady => 'queue_almost_ready',
      };

  static NotificationType fromName(String? value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NotificationType.bookingReceived,
    );
  }
}
