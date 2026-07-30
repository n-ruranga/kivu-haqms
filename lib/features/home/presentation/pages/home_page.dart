import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/core/theme/theme_colors.dart';
import 'package:kivu_haqms/core/widgets/kivu_logo.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/my_appointments_cubit.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/my_appointments_state.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/appointment_card.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/reschedule_sheet.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:kivu_haqms/features/doctors/presentation/widgets/department_icons.dart';
import 'package:kivu_haqms/features/home/presentation/cubit/home_cubit.dart';
import 'package:kivu_haqms/features/home/presentation/cubit/home_state.dart';
import 'package:kivu_haqms/features/home/presentation/widgets/quick_consultation_card.dart';
import 'package:kivu_haqms/features/home/presentation/widgets/queue_status_card.dart';
import 'package:kivu_haqms/features/notifications/presentation/widgets/notification_bell_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiBlocProvider(
      key: ValueKey(authState.user.id),
      providers: [
        BlocProvider(
          create: (context) =>
              MyAppointmentsCubit(context.read<AppointmentRepository>())
                ..watchAppointments(authState.user.id),
        ),
        BlocProvider(
          create: (context) =>
              HomeCubit(context.read<DoctorRepository>())..loadDepartments(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<MyAppointmentsCubit, MyAppointmentsState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
          },
          child: RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthCubit>().state;
              if (auth is AuthAuthenticated) {
                context
                    .read<MyAppointmentsCubit>()
                    .watchAppointments(auth.user.id);
              }
              await context.read<HomeCubit>().loadDepartments();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const _HomeHeader(),
                  const SizedBox(height: 24),
                  const _GreetingSection(),
                  const SizedBox(height: 20),
                  const _QueueSection(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.bookAppointment),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(AppStrings.bookAppointment),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: AppStrings.upcomingAppointment,
                    onViewAll: () => context.go(AppRoutes.schedule),
                  ),
                  const SizedBox(height: 12),
                  const _UpcomingAppointmentSection(),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.quickConsultations,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const _QuickConsultationsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const KivuLogo(),
        const NotificationBellButton(),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final name =
            state is AuthAuthenticated ? state.user.displayName : 'there';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcomeBack,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.mutedText,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, $name',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        );
      },
    );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAppointmentsCubit, MyAppointmentsState>(
      builder: (context, state) {
        final next = state.upcoming.firstOrNull;
        final queueNumber = next?.queueNumber;

        if (queueNumber == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: QueueStatusCard(
            position: queueNumber,
            onTap: () =>
                context.push(AppRoutes.queueTracker, extra: next),
          ),
        );
      },
    );
  }
}

class _UpcomingAppointmentSection extends StatelessWidget {
  const _UpcomingAppointmentSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAppointmentsCubit, MyAppointmentsState>(
      builder: (context, state) {
        if (state.status == MyAppointmentsStatus.initial ||
            state.status == MyAppointmentsStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final upcoming = state.upcoming;
        if (upcoming.isEmpty) {
          return const _NoUpcomingCard();
        }

        final appointment = upcoming.first;
        return AppointmentCard(
          appointment: appointment,
          isBusy: state.busyAppointmentId == appointment.id,
          onCancel: () => _confirmCancel(context, appointment),
          onReschedule: () => showRescheduleSheet(context, appointment),
        );
      },
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    AppointmentEntity appointment,
  ) async {
    final cubit = context.read<MyAppointmentsCubit>();

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this appointment?'),
        content: Text(
          'Your slot with ${appointment.doctorName} will be released for '
          'another patient.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel ?? false) {
      await cubit.cancelAppointment(appointment.id);
    }
  }
}

class _NoUpcomingCard extends StatelessWidget {
  const _NoUpcomingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: context.cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noAppointments,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.noAppointmentsBody,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickConsultationsSection extends StatelessWidget {
  const _QuickConsultationsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.initial ||
            state.status == HomeStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == HomeStatus.failure) {
          return _DepartmentsError(
            message: state.errorMessage ?? 'Could not load departments.',
            onRetry: () => context.read<HomeCubit>().loadDepartments(),
          );
        }

        final departments = state.departments.take(2).toList();
        if (departments.isEmpty) {
          return Text(
            'No departments available yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }

        return Row(
          children: [
            for (var i = 0; i < departments.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: _departmentCard(context, departments[i], i)),
            ],
          ],
        );
      },
    );
  }

  Widget _departmentCard(
    BuildContext context,
    DepartmentEntity department,
    int index,
  ) {
    final isAlt = index.isOdd;
    return QuickConsultationCard(
      title: department.name,
      icon: DepartmentIcons.forKey(department.iconKey),
      iconColor: isAlt ? AppColors.success : AppColors.primary,
      backgroundColor: isAlt ? context.successTintBackground : context.primaryTintBackground,
      onTap: () => context.push(AppRoutes.bookAppointment),
    );
  }
}

class _DepartmentsError extends StatelessWidget {
  const _DepartmentsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: context.cardDecoration(),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onViewAll,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.viewAll,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
