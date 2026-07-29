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

  // Navigation
  static const String navHome = 'Home';
  static const String navSchedule = 'Schedule';
  static const String navDoctors = 'Doctors';
  static const String navProfile = 'Profile';
}
