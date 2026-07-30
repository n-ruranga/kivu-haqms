import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/theme/theme_colors.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_status.dart';

/// Colour-coded pill showing where an appointment sits in its lifecycle.
class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({super.key, required this.status});

  final AppointmentStatus status;

  ({Color background, Color foreground}) _colors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (status) {
      AppointmentStatus.pending => (
          background: isDark
              ? AppColors.warning.withValues(alpha: 0.2)
              : const Color(0xFFFEF3C7),
          foreground:
              isDark ? AppColors.warning : const Color(0xFF92400E),
        ),
      AppointmentStatus.confirmed => (
          background: context.successTintBackground,
          foreground: AppColors.successDark,
        ),
      AppointmentStatus.completed => (
          background: context.primaryTintBackground,
          foreground: AppColors.primaryDark,
        ),
      AppointmentStatus.cancelled => (
          background: isDark
              ? AppColors.error.withValues(alpha: 0.2)
              : const Color(0xFFFEE2E2),
          foreground: isDark ? AppColors.error : const Color(0xFF991B1B),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
