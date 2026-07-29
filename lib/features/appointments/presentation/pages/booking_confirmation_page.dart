import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/core/utils/date_format.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/appointment_status_badge.dart';

/// Success screen shown straight after an appointment is written to Firestore.
///
/// The created appointment arrives through GoRouter's `extra`; if someone opens
/// the route directly there is nothing to show, so we send them to the schedule.
class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key, this.appointment});

  final AppointmentEntity? appointment;

  @override
  Widget build(BuildContext context) {
    final appointment = this.appointment;

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.bookingConfirmed)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This booking is no longer in view.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.schedule),
                  child: const Text(AppStrings.viewMyAppointments),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const _SuccessMark(),
              const SizedBox(height: 24),
              Text(
                AppStrings.bookingConfirmed,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.bookingConfirmedBody,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _SummaryCard(appointment: appointment),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.schedule),
                  child: const Text(AppStrings.viewMyAppointments),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(AppStrings.backToHome),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: AppColors.successLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 46,
        color: AppColors.successDark,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment.departmentName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppointmentStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.person_outline,
            label: 'Doctor',
            value: appointment.doctorName,
          ),
          const Divider(height: 22),
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: AppDateFormat.fullDate(appointment.scheduledAt),
          ),
          const Divider(height: 22),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: 'Time',
            value: AppDateFormat.slotLabel(appointment.timeSlot),
          ),
          const Divider(height: 22),
          _SummaryRow(
            icon: Icons.local_hospital_outlined,
            label: 'Hospital',
            value: appointment.hospital,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
