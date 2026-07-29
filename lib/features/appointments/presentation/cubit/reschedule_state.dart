import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

/// State for the "move this appointment" bottom sheet.
class RescheduleState extends Equatable {
  const RescheduleState({
    this.isLoading = true,
    this.isLoadingSlots = false,
    this.isSaving = false,
    this.isDone = false,
    this.doctor,
    this.selectedDate,
    this.selectedSlot,
    this.bookedSlots = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isLoadingSlots;
  final bool isSaving;
  final bool isDone;
  final DoctorEntity? doctor;
  final DateTime? selectedDate;
  final String? selectedSlot;
  final List<String> bookedSlots;
  final String? errorMessage;

  List<DateTime> get selectableDates {
    final doctor = this.doctor;
    if (doctor == null) return const [];

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return List.generate(14, (i) => startOfToday.add(Duration(days: i)))
        .where(doctor.worksOn)
        .toList();
  }

  List<String> get slots => doctor?.availableSlots ?? const [];

  bool get canSave => selectedDate != null && selectedSlot != null && !isSaving;

  RescheduleState copyWith({
    bool? isLoading,
    bool? isLoadingSlots,
    bool? isSaving,
    bool? isDone,
    DoctorEntity? doctor,
    DateTime? selectedDate,
    String? selectedSlot,
    List<String>? bookedSlots,
    String? errorMessage,
    bool clearSlot = false,
    bool clearError = false,
  }) {
    return RescheduleState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isSaving: isSaving ?? this.isSaving,
      isDone: isDone ?? this.isDone,
      doctor: doctor ?? this.doctor,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot: clearSlot ? null : selectedSlot ?? this.selectedSlot,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingSlots,
        isSaving,
        isDone,
        doctor,
        selectedDate,
        selectedSlot,
        bookedSlots,
        errorMessage,
      ];
}
