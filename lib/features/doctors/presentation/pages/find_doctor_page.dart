import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/constants/app_routes.dart';
import 'package:kivu_haqms/core/constants/app_strings.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';
import 'package:kivu_haqms/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:kivu_haqms/features/doctors/presentation/cubit/find_doctor_cubit.dart';
import 'package:kivu_haqms/features/doctors/presentation/cubit/find_doctor_state.dart';
import 'package:kivu_haqms/features/doctors/presentation/widgets/department_filter_bar.dart';
import 'package:kivu_haqms/features/doctors/presentation/widgets/doctor_list_tile.dart';

/// Searchable, department-filterable directory of doctors. Tapping a doctor
/// opens the booking form with that doctor already selected.
class FindDoctorPage extends StatelessWidget {
  const FindDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FindDoctorCubit(context.read<DoctorRepository>())..load(),
      child: const _FindDoctorView(),
    );
  }
}

class _FindDoctorView extends StatefulWidget {
  const _FindDoctorView();

  @override
  State<_FindDoctorView> createState() => _FindDoctorViewState();
}

class _FindDoctorViewState extends State<_FindDoctorView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBooking(BuildContext context, DoctorEntity doctor) {
    context.push(AppRoutes.bookAppointment, extra: doctor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.findDoctorTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<FindDoctorCubit>().updateQuery(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: AppStrings.searchDoctorsHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<FindDoctorCubit>().updateQuery('');
                                setState(() {});
                              },
                            ),
                    ),
                    onTapOutside: (_) =>
                        FocusScope.of(context).unfocus(),
                  ),
                ],
              ),
            ),
            BlocBuilder<FindDoctorCubit, FindDoctorState>(
              buildWhen: (previous, current) =>
                  previous.departments != current.departments ||
                  previous.selectedDepartmentId != current.selectedDepartmentId,
              builder: (context, state) {
                if (state.departments.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DepartmentFilterBar(
                    departments: state.departments,
                    selectedDepartmentId: state.selectedDepartmentId,
                    onSelected: context.read<FindDoctorCubit>().selectDepartment,
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<FindDoctorCubit, FindDoctorState>(
                builder: (context, state) {
                  if (state.status == FindDoctorStatus.loading ||
                      state.status == FindDoctorStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == FindDoctorStatus.failure &&
                      state.doctors.isEmpty) {
                    return _LoadFailed(
                      message: state.errorMessage ?? AppStrings.couldNotLoadDoctors,
                      onRetry: () => context.read<FindDoctorCubit>().load(),
                    );
                  }

                  final doctors = state.filteredDoctors;
                  if (doctors.isEmpty) {
                    return const _EmptyResults();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorListTile(
                        doctor: doctor,
                        onTap: () => _openBooking(context, doctor),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.noDoctorsFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.noDoctorsFoundBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
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
