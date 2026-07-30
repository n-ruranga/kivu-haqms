import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:kivu_haqms/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final unreadCount = state.unreadCount;

        return IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
            backgroundColor: AppColors.error,
            child: const Icon(Icons.notifications_outlined),
          ),
          color: AppColors.primary,
          iconSize: 26,
        );
      },
    );
  }
}
