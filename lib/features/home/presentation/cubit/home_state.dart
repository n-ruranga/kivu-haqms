import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';

enum HomeStatus { initial, loading, loaded, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.departments = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final List<DepartmentEntity> departments;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<DepartmentEntity>? departments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      departments: departments ?? this.departments,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, departments, errorMessage];
}
