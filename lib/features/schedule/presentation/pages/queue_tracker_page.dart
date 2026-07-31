import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/core/theme/theme_colors.dart';
import 'package:kivu_haqms/core/utils/date_format.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/appointment_status_badge.dart';
import 'package:kivu_haqms/features/home/presentation/widgets/queue_status_card.dart';
import 'package:kivu_haqms/features/schedule/presentation/cubit/queue_cubit.dart';
import 'package:kivu_haqms/features/schedule/presentation/cubit/queue_state.dart';

/// Live queue position for one appointment, computed from every other
/// appointment booked with the same doctor on the same day.
class QueueTrackerPage extends StatelessWidget {
  const QueueTrackerPage({super.key, this.appointment});

  /// Handed over via the route's `extra` — the appointment being tracked.
  final AppointmentEntity? appointment;

  @override
  Widget build(BuildContext context) {
    final appointment = this.appointment;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.queueTrackerTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: appointment == null
            ? const _NoActiveQueue()
            : BlocProvider(
                create: (context) =>
                    QueueCubit(context.read<AppointmentRepository>())
                      ..track(appointment),
                child: _QueueTrackerView(appointment: appointment),
              ),
      ),
    );
  }
}

class _QueueTrackerView extends StatelessWidget {
  const _QueueTrackerView({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueCubit, QueueState>(
      builder: (context, state) {
        if (!state.isTrackable) {
          return const _NoActiveQueue(
            message: AppStrings.queueAppointmentDone,
          );
        }

        if (state.status == QueueStatus.loading &&
            state.doctorAppointmentsToday.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QueueStatusCard(
                position: state.position ?? appointment.queueNumber ?? 1,
                totalInQueue: state.totalInQueue,
                estimatedWaitMinutes: state.estimatedWaitMinutes,
              ),
              const SizedBox(height: 12),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 12),
              _AppointmentSummaryCard(appointment: appointment),
            ],
          ),
        );
      },
    );
  }
}

class _AppointmentSummaryCard extends StatelessWidget {
  const _AppointmentSummaryCard({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.doctorName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AppointmentStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            appointment.specialty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.local_hospital_outlined,
            text: appointment.hospital,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: AppDateFormat.relativeDateTime(
              appointment.scheduledAt,
              appointment.timeSlot,
            ),
          ),
          if (appointment.queueNumber case final ticket?) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              text: 'Ticket #$ticket',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _NoActiveQueue extends StatelessWidget {
  const _NoActiveQueue({this.message = AppStrings.noActiveQueueBody});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pending_actions_outlined,
              size: 40,
              color: context.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.noActiveQueue,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
