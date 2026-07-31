import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

/// Read-only directory of departments and the doctors inside them.
///
/// Appointments are written through `AppointmentRepository`; this contract only
/// supplies the reference data the booking form needs.
abstract interface class DoctorRepository {
  /// All bookable departments, ordered by name.
  Future<List<DepartmentEntity>> getDepartments();

  /// Every doctor accepting patients, across all departments.
  Future<List<DoctorEntity>> getAllDoctors();

  /// Doctors belonging to [departmentId] who are accepting patients.
  Future<List<DoctorEntity>> getDoctorsByDepartment(String departmentId);

  /// A single doctor, or `null` when the document no longer exists.
  Future<DoctorEntity?> getDoctorById(String doctorId);
}
