import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/utils/date_format.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_type.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread ? AppColors.primaryLight.withValues(alpha: 0.35) : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBackground(notification.type),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _icon(notification.type),
                  color: _iconColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight:
                                      isUnread ? FontWeight.w700 : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeLabel(notification.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) => switch (type) {
        NotificationType.bookingReceived => Icons.event_note_outlined,
        NotificationType.appointmentConfirmed => Icons.check_circle_outline,
        NotificationType.appointmentCancelled => Icons.event_busy_outlined,
        NotificationType.appointmentRescheduled => Icons.update_outlined,
        NotificationType.appointmentCompleted => Icons.medical_services_outlined,
        NotificationType.appointmentReminder => Icons.alarm_outlined,
        NotificationType.queueAlmostReady => Icons.people_outline,
      };

  Color _iconBackground(NotificationType type) => switch (type) {
        NotificationType.appointmentConfirmed ||
        NotificationType.appointmentCompleted =>
          AppColors.successLight,
        NotificationType.appointmentCancelled => AppColors.error.withValues(alpha: 0.12),
        NotificationType.queueAlmostReady => AppColors.warning.withValues(alpha: 0.15),
        _ => AppColors.primaryLight,
      };

  Color _iconColor(NotificationType type) => switch (type) {
        NotificationType.appointmentConfirmed ||
        NotificationType.appointmentCompleted =>
          AppColors.successDark,
        NotificationType.appointmentCancelled => AppColors.error,
        NotificationType.queueAlmostReady => AppColors.warning,
        _ => AppColors.primary,
      };

  String _timeLabel(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return AppDateFormat.fullDate(date);
  }
}
