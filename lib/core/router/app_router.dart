import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/login_page.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/sign_up_page.dart';
import 'package:kivu_haqms/features/doctors/presentation/pages/book_appointment_page.dart';
import 'package:kivu_haqms/features/doctors/presentation/pages/booking_confirmation_page.dart';
import 'package:kivu_haqms/features/doctors/presentation/pages/find_doctor_page.dart';
import 'package:kivu_haqms/features/home/presentation/pages/home_page.dart';
import 'package:kivu_haqms/features/profile/presentation/pages/profile_page.dart';
import 'package:kivu_haqms/features/schedule/presentation/pages/queue_tracker_page.dart';
import 'package:kivu_haqms/features/schedule/presentation/pages/schedule_page.dart';
import 'package:kivu_haqms/features/shell/presentation/pages/main_shell_page.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    routes: [
      // ── Auth flow (outside shell) ──────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),

      // ── Main app shell with bottom navigation ──────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) => const SchedulePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.doctors,
                builder: (context, state) => const FindDoctorPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ── Feature screens pushed on top of shell ─────────────────────
      GoRoute(
        path: AppRoutes.bookAppointment,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookAppointmentPage(),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookingConfirmationPage(),
      ),
      GoRoute(
        path: AppRoutes.queueTracker,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QueueTrackerPage(),
      ),
    ],
  );
}
