import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';

/// Shows the patient's queue position from their next appointment.
///
/// Live wait-time / people-ahead APIs are not ready yet, so those rows are
/// optional and only shown when callers have real values.
class QueueStatusCard extends StatelessWidget {
  const QueueStatusCard({
    super.key,
    required this.position,
    this.totalInQueue,
    this.estimatedWaitMinutes,
    this.onTap,
  });

  final int position;
  final int? totalInQueue;
  final int? estimatedWaitMinutes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = totalInQueue != null && totalInQueue! > 0
        ? ((totalInQueue! - position + 1) / totalInQueue!).clamp(0.0, 1.0)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryGradientEnd],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.queuePosition,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                  ),
                  Icon(
                    Icons.pending_actions_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '#$position in line',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
              if (estimatedWaitMinutes != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.estimatedWait}: $estimatedWaitMinutes mins',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  'Tap to open queue tracker',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
