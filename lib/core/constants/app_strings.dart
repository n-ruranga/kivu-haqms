/// Centralized user-facing strings for the KIVU app.
abstract final class AppStrings {
  static const String appName = 'KIVU';
  static const String tagline = 'Book smarter, wait less';

  // Auth — Duke will replace these placeholders with full screens.
  static const String welcome = 'Welcome';
  static const String enterPhone = 'Enter your phone number to get started.';
  static const String verifyNumber = 'Verify your number';
  static const String enterOtp = 'Enter the 6-digit code we sent to your phone.';

  // Home
  static const String welcomeBack = 'WELCOME BACK';
  static const String queuePosition = 'Your queue position';
  static const String bookAppointment = 'Book appointment';
  static const String upcomingAppointment = 'Upcoming Appointment';
  static const String viewAll = 'View All';
  static const String quickConsultations = 'Quick Consultations';
  static const String estimatedWait = 'Estimated wait';

  // Appointment booking — Kethia
  static const String bookAppointmentTitle = 'Book Appointment';
  static const String chooseDepartment = 'Choose a department';
  static const String chooseDoctor = 'Choose a doctor';
  static const String chooseDate = 'Pick a date';
  static const String chooseTime = 'Pick a time';
  static const String reasonForVisit = 'Reason for visit';
  static const String confirmBooking = 'Confirm booking';
  static const String bookingConfirmed = 'Appointment requested';
  static const String bookingConfirmedBody =
      'Your request has been sent to the hospital. You will get a notification '
      'once it is confirmed.';
  static const String viewMyAppointments = 'View my appointments';
  static const String backToHome = 'Back to home';
  static const String myAppointments = 'My Appointments';
  static const String upcoming = 'Upcoming';
  static const String pastAppointments = 'Past';
  static const String noAppointments = 'No appointments yet';
  static const String noAppointmentsBody =
      'Book your first appointment and it will show up here.';
  static const String cancelAppointment = 'Cancel';
  static const String rescheduleAppointment = 'Reschedule';

  // Find a doctor
  static const String findDoctorTitle = 'Find a Doctor';
  static const String searchDoctorsHint = 'Search doctors or specialties';
  static const String allDepartments = 'All';
  static const String noDoctorsFound = 'No doctors found';
  static const String noDoctorsFoundBody =
      'Try a different search or department filter.';
  static const String couldNotLoadDoctors = 'Could not load the doctor directory.';

  // Queue tracker
  static const String queueTrackerTitle = 'Queue Tracker';
  static const String peopleAhead = 'people ahead of you';
  static const String totalInQueueLabel = 'Total in queue today';
  static const String noActiveQueue = 'No active queue';
  static const String noActiveQueueBody =
      'Book an appointment to see your live queue position here.';
  static const String queueAppointmentDone =
      'This appointment has already been seen or cancelled.';

  // Navigation
  static const String navHome = 'Home';
  static const String navSchedule = 'Schedule';
  static const String navDoctors = 'Doctors';
  static const String navProfile = 'Profile';

  // Profile
  static const String profileTitle = 'Profile';
  static const String editProfile = 'Edit';
  static const String editProfileSubtitle =
      'Update your personal details and emergency contact.';
  static const String personalInfo = 'Personal information';
  static const String preferences = 'Preferences';
  static const String account = 'Account';
  static const String phoneNumber = 'Phone number';
  static const String dateOfBirth = 'Date of birth';
  static const String emergencyContact = 'Emergency contact';
  static const String emergencyContactName = 'Contact name';
  static const String emergencyContactPhone = 'Contact phone';
  static const String pushNotifications = 'Push notifications';
  static const String pushNotificationsDesc =
      'Receive alerts about queue updates and appointments.';
  static const String appointmentReminders = 'Appointment reminders';
  static const String appointmentRemindersDesc =
      'Get reminded before your upcoming appointments.';
  static const String resetPassword = 'Reset password';
  static const String resetPasswordDesc =
      'Send a password reset link to your email.';
  static const String signOut = 'Sign out';
  static const String notProvided = 'Not provided';
  static const String profileLoadError = 'Could not load your profile.';
  static const String tryAgain = 'Try again';
  static const String fullName = 'Full name';
  static const String fullNameRequired = 'Enter your full name';
  static const String email = 'Email';
  static const String emailReadOnly = 'Email cannot be changed here.';
  static const String selectDate = 'Select date';
  static const String clearDate = 'Clear date';
  static const String saveChanges = 'Save changes';
  static const String profileUpdated = 'Profile updated successfully.';

  static String resetPasswordSent(String email) =>
      'Password reset link sent to $email.';

  // Notifications
  static const String notificationsTitle = 'Notifications';
  static const String noNotifications = 'No notifications yet';
  static const String noNotificationsBody =
      'Updates about your appointments and queue position will appear here.';
  static const String markAllRead = 'Mark all read';
  static const String notificationsLoadError = 'Could not load notifications.';
}
