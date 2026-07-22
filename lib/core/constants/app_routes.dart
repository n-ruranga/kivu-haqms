/// Named route paths for GoRouter.
abstract final class AppRoutes {
  // Auth — owner: Duke
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/sign-up';

  // Main shell tabs
  static const String home = '/home';
  static const String schedule = '/schedule';
  static const String doctors = '/doctors';
  static const String profile = '/profile';

  // Feature screens (pushed on top of shell)
  static const String bookAppointment = '/book-appointment';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String queueTracker = '/queue-tracker';
}
