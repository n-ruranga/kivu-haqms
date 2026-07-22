import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/router/go_router_refresh_stream.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/login_page.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/sign_up_page.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/splash_page.dart';
import 'package:kivu_haqms/features/doctors/presentation/pages/book_appointment_page.dart';
import 'package:kivu_haqms/features/doctors/presentation/pages/booking_confirmation_page.dart';
import 'package:kivu_haqms/features/doctors/presentation/pages/find_doctor_page.dart';
import 'package:kivu_haqms/features/home/presentation/pages/home_page.dart';
import 'package:kivu_haqms/features/profile/presentation/pages/profile_page.dart';
import 'package:kivu_haqms/features/schedule/presentation/pages/queue_tracker_page.dart';
import 'package:kivu_haqms/features/schedule/presentation/pages/schedule_page.dart';
import 'package:kivu_haqms/features/shell/presentation/pages/main_shell_page.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final location = state.matchedLocation;
        final isSplashRoute = location == AppRoutes.splash;
        final isAuthRoute = location == AppRoutes.login || location == AppRoutes.signUp;

        // Still checking session — stay put.
        if (authState is AuthInitial || authState is AuthLoading) {
          return isSplashRoute ? null : AppRoutes.splash;
        }

        final isLoggedIn = authState is AuthAuthenticated;

        if (!isLoggedIn && !isAuthRoute) {
          return AppRoutes.login;
        }

        if (isLoggedIn && (isAuthRoute || isSplashRoute)) {
          return AppRoutes.home;
        }

        if (isSplashRoute){
          return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          builder: (context, state) => const SignUpPage(),
        ),
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
        GoRoute(
          path: AppRoutes.bookAppointment,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const BookAppointmentPage(),
        ),
        GoRoute(
          path: AppRoutes.bookingConfirmation,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const BookingConfirmationPage(),
        ),
        GoRoute(
          path: AppRoutes.queueTracker,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const QueueTrackerPage(),
        ),
      ],
    );
  }
}
