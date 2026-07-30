import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_entity.dart';
import 'package:kivu_haqms/features/notifications/domain/entities/notification_type.dart';
import 'package:kivu_haqms/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:kivu_haqms/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:kivu_haqms/features/notifications/presentation/widgets/notification_list_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.notificationsTitle),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();

              return TextButton(
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllAsRead(),
                child: const Text(AppStrings.markAllRead),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.initial ||
              state.status == NotificationsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationsStatus.failure &&
              state.notifications.isEmpty) {
            return _EmptyState(
              icon: Icons.error_outline,
              title: AppStrings.notificationsLoadError,
              subtitle: state.errorMessage,
            );
          }

          if (state.notifications.isEmpty) {
            return const _EmptyState(
              icon: Icons.notifications_none_outlined,
              title: AppStrings.noNotifications,
              subtitle: AppStrings.noNotificationsBody,
            );
          }

          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: 72,
              color: AppColors.border,
            ),
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return NotificationListTile(
                notification: notification,
                onTap: () => _onNotificationTap(context, notification),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) async {
    final cubit = context.read<NotificationsCubit>();
    if (!notification.isRead) {
      await cubit.markAsRead(notification.id);
    }

    final appointmentId = notification.appointmentId;
    if (appointmentId == null || !context.mounted) return;

    final appointment = await context
        .read<AppointmentRepository>()
        .getAppointmentById(appointmentId);

    if (!context.mounted || appointment == null) return;

    if (notification.type == NotificationType.queueAlmostReady &&
        appointment.status.isActive) {
      context.push(AppRoutes.queueTracker, extra: appointment);
    } else {
      context.go(AppRoutes.schedule);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
