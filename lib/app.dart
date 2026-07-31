import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/router/app_router.dart';
import 'package:kivu_haqms/core/theme/app_theme.dart';
import 'package:kivu_haqms/features/appointments/data/repositories/firestore_appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/doctors/data/repositories/firestore_doctor_repository.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:kivu_haqms/features/profile/data/repositories/firestore_profile_repository.dart';
import 'package:kivu_haqms/features/profile/domain/repositories/profile_repository.dart';
import 'package:kivu_haqms/features/notifications/data/repositories/firestore_notification_repository.dart';
import 'package:kivu_haqms/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kivu_haqms/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:kivu_haqms/features/profile/presentation/cubit/profile_cubit.dart';

class KivuApp extends StatefulWidget {
  const KivuApp({super.key});

  @override
  State<KivuApp> createState() => _KivuAppState();
}

class _KivuAppState extends State<KivuApp> {
  late final AuthRepository _authRepository;
  late final DoctorRepository _doctorRepository;
  late final AppointmentRepository _appointmentRepository;
  late final ProfileRepository _profileRepository;
  late final NotificationRepository _notificationRepository;
  late final AuthCubit _authCubit;
  late final ProfileCubit _profileCubit;
  late final NotificationsCubit _notificationsCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepository();
    _doctorRepository = FirestoreDoctorRepository();
    _appointmentRepository = FirestoreAppointmentRepository();
    _profileRepository = FirestoreProfileRepository(
      authRepository: _authRepository,
    );
    _notificationRepository = FirestoreNotificationRepository();
    _authCubit = AuthCubit(_authRepository);
    _profileCubit = ProfileCubit(_profileRepository);
    _notificationsCubit = NotificationsCubit(
      _notificationRepository,
      _appointmentRepository,
      _profileRepository,
      _authRepository,
    );
    _router = AppRouter.create(_authCubit);
  }

  @override
  void dispose() {
    _notificationsCubit.close();
    _profileCubit.close();
    _authCubit.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<DoctorRepository>.value(value: _doctorRepository),
        RepositoryProvider<AppointmentRepository>.value(
          value: _appointmentRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(value: _profileRepository),
        RepositoryProvider<NotificationRepository>.value(
          value: _notificationRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<ProfileCubit>.value(value: _profileCubit),
          BlocProvider<NotificationsCubit>.value(value: _notificationsCubit),
        ],
        child: MaterialApp.router(
          title: 'KIVU',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
