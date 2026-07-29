import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/reschedule_cubit.dart';
import 'package:kivu_haqms/features/appointments/presentation/cubit/reschedule_state.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/date_strip.dart';
import 'package:kivu_haqms/features/appointments/presentation/widgets/time_slot_grid.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';

/// Opens the reschedule sheet. Resolves to `true` when the appointment moved.
Future<bool> showRescheduleSheet(
  BuildContext context,
  AppointmentEntity appointment,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => BlocProvider(
      create: (_) => RescheduleCubit(
        appointment,
        context.read<DoctorRepository>(),
        context.read<AppointmentRepository>(),
      )..load(),
      child: _RescheduleSheet(appointment: appointment),
    ),
  );

  return result ?? false;
}

class _RescheduleSheet extends StatelessWidget {
  const _RescheduleSheet({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RescheduleCubit, RescheduleState>(
      listenWhen: (previous, current) =>
          previous.isDone != current.isDone ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.isDone) {
          Navigator.of(context).pop(true);
          return;
        }

        if (state.errorMessage != null) {
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
        final cubit = context.read<RescheduleCubit>();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reschedule appointment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'with ${appointment.doctorName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    DateStrip(
                      dates: state.selectableDates,
                      selectedDate: state.selectedDate,
                      onSelected: cubit.selectDate,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: state.isLoadingSlots
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : TimeSlotGrid(
                              slots: state.slots,
                              bookedSlots: state.bookedSlots,
                              selectedSlot: state.selectedSlot,
                              onSelected: cubit.selectSlot,
                            ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.canSave ? cubit.save : null,
                          child: state.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Move appointment'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
