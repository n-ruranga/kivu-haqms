/// Lifecycle of an appointment.
///
/// Stored in Firestore as the lowercase [name] (`'pending'`, `'confirmed'`...)
/// rather than an index, so reordering this enum never corrupts existing data.
enum AppointmentStatus {
  /// Created by the patient, waiting for the hospital to confirm.
  pending,

  /// Accepted by the hospital — the patient has a slot.
  confirmed,

  /// The patient has been seen.
  completed,

  /// Called off by either side.
  cancelled;

  static AppointmentStatus fromName(String? value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AppointmentStatus.pending,
    );
  }

  String get label => switch (this) {
        AppointmentStatus.pending => 'Pending',
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.completed => 'Completed',
        AppointmentStatus.cancelled => 'Cancelled',
      };

  /// Only future, non-terminal appointments may be cancelled or rescheduled.
  bool get isActive =>
      this == AppointmentStatus.pending || this == AppointmentStatus.confirmed;
}
