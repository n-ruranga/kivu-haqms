import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:kivu_haqms/features/home/presentation/cubit/home_state.dart';

/// Loads directory data the home dashboard needs (quick consultations).
///
/// Appointments stay on [MyAppointmentsCubit] so cancel/reschedule stay shared
/// with the Schedule tab.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._doctorRepository) : super(const HomeState());

  final DoctorRepository _doctorRepository;

  Future<void> loadDepartments() async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    try {
      final departments = await _doctorRepository.getDepartments();
      emit(state.copyWith(
        status: HomeStatus.loaded,
        departments: departments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
