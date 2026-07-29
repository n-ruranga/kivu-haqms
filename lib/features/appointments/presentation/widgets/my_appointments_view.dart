import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/my_appointments_cubit.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/my_appointments_state.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/appointment_card.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/reschedule_sheet.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';

/// Live list of the signed-in patient's appointments, with cancel and
/// reschedule actions.
///
/// Self-contained (provides its own cubit) so any screen can embed it — the
/// Schedule tab uses it today.
class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider(
      key: ValueKey(authState.user.id),
      create: (context) =>
          MyAppointmentsCubit(context.read<AppointmentRepository>())
            ..watchAppointments(authState.user.id),
      child: const _MyAppointmentsList(),
    );
  }
}

class _MyAppointmentsList extends StatelessWidget {
  const _MyAppointmentsList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyAppointmentsCubit, MyAppointmentsState>(
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
      builder: (context, state) {
        if (state.status == MyAppointmentsStatus.initial ||
            state.status == MyAppointmentsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isEmpty) {
          return const _EmptyState();
        }

        final upcoming = state.upcoming;
        final past = state.past;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (upcoming.isNotEmpty) ...[
              _SectionTitle(
                title: AppStrings.upcoming,
                count: upcoming.length,
              ),
              const SizedBox(height: 12),
              for (final appointment in upcoming) ...[
                AppointmentCard(
                  appointment: appointment,
                  isBusy: state.busyAppointmentId == appointment.id,
                  onCancel: () => _confirmCancel(context, appointment),
                  onReschedule: () => showRescheduleSheet(context, appointment),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
            ],
            if (past.isNotEmpty) ...[
              _SectionTitle(
                title: AppStrings.pastAppointments,
                count: past.length,
              ),
              const SizedBox(height: 12),
              for (final appointment in past) ...[
                AppointmentCard(appointment: appointment),
                const SizedBox(height: 12),
              ],
            ],
          ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noAppointments,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.noAppointmentsBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
