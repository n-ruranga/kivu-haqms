import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/appointments/domain/entities/appointment_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

enum BookingStatus { initial, loading, ready, submitting, success, failure }

/// The booking form is one screen with four dependent choices, so it uses a
/// single state object with `copyWith` rather than the sealed-class style used
/// by `AuthState` — every field has to survive each step.
class BookingState extends Equatable {
  const BookingState({
    this.status = BookingStatus.initial,
    this.departments = const [],
    this.doctors = const [],
    this.bookedSlots = const [],
    this.selectedDepartment,
    this.selectedDoctor,
    this.selectedDate,
    this.selectedSlot,
    this.reason = '',
    this.isLoadingDoctors = false,
    this.isLoadingSlots = false,
    this.createdAppointment,
    this.errorMessage,
  });

  final BookingStatus status;
  final List<DepartmentEntity> departments;
  final List<DoctorEntity> doctors;

  /// `HH:mm` slots already taken for the selected doctor on the selected date.
  final List<String> bookedSlots;

  final DepartmentEntity? selectedDepartment;
  final DoctorEntity? selectedDoctor;
  final DateTime? selectedDate;
  final String? selectedSlot;
  final String reason;

  final bool isLoadingDoctors;
  final bool isLoadingSlots;

  final AppointmentEntity? createdAppointment;
  final String? errorMessage;

  /// The next 14 days the selected doctor actually works.
  List<DateTime> get selectableDates {
    final doctor = selectedDoctor;
    if (doctor == null) return const [];

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return List.generate(14, (i) => startOfToday.add(Duration(days: i)))
        .where(doctor.worksOn)
        .toList();
  }

  /// Every slot the doctor offers, minus times that have already passed today.
  List<String> get slotsForSelectedDate {
    final doctor = selectedDoctor;
    final date = selectedDate;
    if (doctor == null || date == null) return const [];

    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    if (!isToday) return doctor.availableSlots;

    return doctor.availableSlots.where((slot) {
      final parts = slot.split(':');
      final slotTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.tryParse(parts.first) ?? 0,
        int.tryParse(parts.last) ?? 0,
      );
      return slotTime.isAfter(now);
    }).toList();
  }

  bool isSlotBooked(String slot) => bookedSlots.contains(slot);

  bool get canSubmit =>
      selectedDepartment != null &&
      selectedDoctor != null &&
      selectedDate != null &&
      selectedSlot != null &&
      status != BookingStatus.submitting;

  BookingState copyWith({
    BookingStatus? status,
    List<DepartmentEntity>? departments,
    List<DoctorEntity>? doctors,
    List<String>? bookedSlots,
    DepartmentEntity? selectedDepartment,
    DoctorEntity? selectedDoctor,
    DateTime? selectedDate,
    String? selectedSlot,
    String? reason,
    bool? isLoadingDoctors,
    bool? isLoadingSlots,
    AppointmentEntity? createdAppointment,
    String? errorMessage,
    bool clearDoctor = false,
    bool clearDate = false,
    bool clearSlot = false,
    bool clearError = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      departments: departments ?? this.departments,
      doctors: doctors ?? this.doctors,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedDoctor: clearDoctor ? null : selectedDoctor ?? this.selectedDoctor,
      selectedDate: clearDate ? null : selectedDate ?? this.selectedDate,
      selectedSlot: clearSlot ? null : selectedSlot ?? this.selectedSlot,
      reason: reason ?? this.reason,
      isLoadingDoctors: isLoadingDoctors ?? this.isLoadingDoctors,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      createdAppointment: createdAppointment ?? this.createdAppointment,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        departments,
        doctors,
        bookedSlots,
        selectedDepartment,
        selectedDoctor,
        selectedDate,
        selectedSlot,
        reason,
        isLoadingDoctors,
        isLoadingSlots,
        createdAppointment,
        errorMessage,
      ];
}
