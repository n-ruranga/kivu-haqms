import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

enum FindDoctorStatus { initial, loading, loaded, failure }

/// State for the "Find a Doctor" directory: the full doctor list plus a
/// department filter and free-text search applied client-side.
class FindDoctorState extends Equatable {
  const FindDoctorState({
    this.status = FindDoctorStatus.initial,
    this.departments = const [],
    this.doctors = const [],
    this.selectedDepartmentId,
    this.query = '',
    this.errorMessage,
  });

  final FindDoctorStatus status;
  final List<DepartmentEntity> departments;
  final List<DoctorEntity> doctors;

  /// `null` means "All departments".
  final String? selectedDepartmentId;
  final String query;
  final String? errorMessage;

  List<DoctorEntity> get filteredDoctors {
    final normalizedQuery = query.trim().toLowerCase();
    final departmentId = selectedDepartmentId;

    return doctors.where((doctor) {
      if (departmentId != null && doctor.departmentId != departmentId) {
        return false;
      }
      if (normalizedQuery.isEmpty) return true;

      return doctor.fullName.toLowerCase().contains(normalizedQuery) ||
          doctor.specialty.toLowerCase().contains(normalizedQuery) ||
          doctor.hospital.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  FindDoctorState copyWith({
    FindDoctorStatus? status,
    List<DepartmentEntity>? departments,
    List<DoctorEntity>? doctors,
    String? selectedDepartmentId,
    String? query,
    String? errorMessage,
    bool clearSelectedDepartment = false,
    bool clearError = false,
  }) {
    return FindDoctorState(
      status: status ?? this.status,
      departments: departments ?? this.departments,
      doctors: doctors ?? this.doctors,
      selectedDepartmentId: clearSelectedDepartment
          ? null
          : selectedDepartmentId ?? this.selectedDepartmentId,
      query: query ?? this.query,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        departments,
        doctors,
        selectedDepartmentId,
        query,
        errorMessage,
      ];
}
