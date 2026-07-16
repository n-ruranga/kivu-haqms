import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/core/widgets/kivu_logo.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';
import 'package:kivu_haqms/features/home/presentation/widgets/quick_consultation_card.dart';
import 'package:kivu_haqms/features/home/presentation/widgets/queue_status_card.dart';
import 'package:kivu_haqms/features/home/presentation/widgets/upcoming_appointment_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _HomeHeader(),
              const SizedBox(height: 24),
              _GreetingSection(),
              const SizedBox(height: 20),
              const QueueStatusCard(
                position: 4,
                totalInQueue: 10,
                estimatedWaitMinutes: 15,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.bookAppointment),
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
              const UpcomingAppointmentCard(
                doctorName: 'Dr. Nsengimana',
                specialty: 'Cardiology Specialist',
                hospital: 'Kigali Central Hospital',
                dateTime: 'Tomorrow at 10:00 AM',
                status: 'Confirmed',
              ),
              const SizedBox(height: 28),
              Text(
                AppStrings.quickConsultations,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: QuickConsultationCard(
                      title: 'General',
                      icon: Icons.medical_services_outlined,
                      iconColor: AppColors.primary,
                      backgroundColor: AppColors.primaryLight,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: QuickConsultationCard(
                      title: 'Pediatrics',
                      icon: Icons.child_care_outlined,
                      iconColor: AppColors.success,
                      backgroundColor: AppColors.successLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const KivuLogo(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.primary,
          iconSize: 26,
        ),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final name = state is AuthAuthenticated ? state.user.displayName : 'there';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcomeBack,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
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
