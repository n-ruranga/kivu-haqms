import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/my_appointments_view.dart';

/// Schedule tab. The appointment list comes from the appointments feature
/// (Kethia) — Naillah's queue tracker slots in above or below it.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myAppointments),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.bookAppointment),
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            tooltip: AppStrings.bookAppointment,
          ),
        ],
      ),
      body: const SafeArea(child: MyAppointmentsView()),
    );
  }
}
