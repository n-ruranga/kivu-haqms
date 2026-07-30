import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:kivu_haqms/features/doctors/presentation/cubit/find_doctor_state.dart';

/// Loads the full department + doctor directory once; filtering by
/// department and search query happens client-side in [FindDoctorState].
class FindDoctorCubit extends Cubit<FindDoctorState> {
  FindDoctorCubit(this._repository) : super(const FindDoctorState());

  final DoctorRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: FindDoctorStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        _repository.getDepartments(),
        _repository.getAllDoctors(),
      ]);

      emit(state.copyWith(
        status: FindDoctorStatus.loaded,
        departments: results[0] as List<DepartmentEntity>,
        doctors: results[1] as List<DoctorEntity>,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FindDoctorStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void selectDepartment(String? departmentId) {
    emit(state.copyWith(
      selectedDepartmentId: departmentId,
      clearSelectedDepartment: departmentId == null,
    ));
  }

  void updateQuery(String query) => emit(state.copyWith(query: query));
}
