import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/core/utils/date_format.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/booking_cubit.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/booking_state.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/booking_step_header.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/date_strip.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/department_selector.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/doctor_option_tile.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/time_slot_grid.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';

/// Step-by-step booking form: department -> doctor -> date -> time -> confirm.
class BookAppointmentPage extends StatelessWidget {
  const BookAppointmentPage({super.key, this.initialDoctor});

  /// Passed when opened from "Find a Doctor" so steps 1-2 are pre-filled.
  final DoctorEntity? initialDoctor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingCubit(
        context.read<DoctorRepository>(),
        context.read<AppointmentRepository>(),
        initialDoctor: initialDoctor,
      )..loadDepartments(),
      child: const _BookAppointmentView(),
    );
  }
}

class _BookAppointmentView extends StatelessWidget {
  const _BookAppointmentView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.bookAppointmentTitle),
        centerTitle: true,
      ),
      body: BlocConsumer<BookingCubit, BookingState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == BookingStatus.success &&
              state.createdAppointment != null) {
            context.pushReplacement(
              AppRoutes.bookingConfirmation,
              extra: state.createdAppointment,
            );
          }

          if (state.status == BookingStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.status == BookingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BookingStatus.failure && state.departments.isEmpty) {
            return _LoadFailed(
              message: state.errorMessage ?? 'Could not load departments.',
              onRetry: () => context.read<BookingCubit>().loadDepartments(),
            );
          }

          return _BookingForm(state: state);
        },
      ),
      bottomNavigationBar: const _ConfirmBar(),
    );
  }
}

class _BookingForm extends StatelessWidget {
  const _BookingForm({required this.state});

  final BookingState state;

  static const _sidePadding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1 — department
          Padding(
            padding: _sidePadding,
            child: BookingStepHeader(
              step: 1,
              title: AppStrings.chooseDepartment,
              isComplete: state.selectedDepartment != null,
            ),
          ),
          const SizedBox(height: 12),
          DepartmentSelector(
            departments: state.departments,
            selectedDepartment: state.selectedDepartment,
            onSelected: cubit.selectDepartment,
          ),
          const SizedBox(height: 24),

          // Step 2 — doctor
          Padding(
            padding: _sidePadding,
            child: BookingStepHeader(
              step: 2,
              title: AppStrings.chooseDoctor,
              isComplete: state.selectedDoctor != null,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: _sidePadding,
            child: _DoctorSection(state: state),
          ),

          // Steps 3 and 4 only make sense once a doctor is chosen.
          if (state.selectedDoctor != null) ...[
            const SizedBox(height: 24),
            Padding(
              padding: _sidePadding,
              child: BookingStepHeader(
                step: 3,
                title: AppStrings.chooseDate,
                isComplete: state.selectedDate != null,
              ),
            ),
            const SizedBox(height: 12),
            DateStrip(
              dates: state.selectableDates,
              selectedDate: state.selectedDate,
              onSelected: cubit.selectDate,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: _sidePadding,
              child: BookingStepHeader(
                step: 4,
                title: AppStrings.chooseTime,
                isComplete: state.selectedSlot != null,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: _sidePadding,
              child: state.isLoadingSlots
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : TimeSlotGrid(
                      slots: state.slotsForSelectedDate,
                      bookedSlots: state.bookedSlots,
                      selectedSlot: state.selectedSlot,
                      onSelected: cubit.selectSlot,
                    ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: _sidePadding,
              child: _ReasonField(onChanged: cubit.updateReason),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorSection extends StatelessWidget {
  const _DoctorSection({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    if (state.selectedDepartment == null) {
      return const _Hint(text: 'Pick a department to see its doctors.');
    }

    if (state.isLoadingDoctors) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.doctors.isEmpty) {
      return const _Hint(
        text: 'No doctors are accepting patients in this department yet.',
      );
    }

    final cubit = context.read<BookingCubit>();

    return Column(
      children: [
        for (final doctor in state.doctors) ...[
          DoctorOptionTile(
            doctor: doctor,
            isSelected: state.selectedDoctor?.id == doctor.id,
            onTap: () => cubit.selectDoctor(doctor),
          ),
          if (doctor != state.doctors.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reasonForVisit,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        TextField(
          maxLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Briefly describe your symptoms (optional)',
          ),
        ),
      ],
    );
  }
}

/// Sticky summary + submit button.
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isSubmitting = state.status == BookingStatus.submitting;
        final summary = _summaryFor(state);

        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (summary != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.event_available_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.canSubmit && !isSubmitting
                      ? () => _submit(context)
                      : null,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.confirmBooking),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _summaryFor(BookingState state) {
    final doctor = state.selectedDoctor;
    final date = state.selectedDate;
    final slot = state.selectedSlot;

    if (doctor == null || date == null || slot == null) return null;

    return '${doctor.fullName} · ${AppDateFormat.relativeDateTime(date, slot)}';
  }

  void _submit(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to book.')),
      );
      return;
    }

    context.read<BookingCubit>().submitBooking(
          patientId: authState.user.id,
          patientName: authState.user.displayName,
        );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
