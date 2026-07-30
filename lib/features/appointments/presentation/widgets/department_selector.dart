import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/department_entity.dart';
import 'package:kivu_haqms/features/doctors/presentation/widgets/department_icons.dart';

/// Horizontally scrolling list of departments — step 1 of the booking form.
class DepartmentSelector extends StatelessWidget {
  const DepartmentSelector({
    super.key,
    required this.departments,
    required this.selectedDepartment,
    required this.onSelected,
  });

  final List<DepartmentEntity> departments;
  final DepartmentEntity? selectedDepartment;
  final ValueChanged<DepartmentEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: departments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final department = departments[index];

          return _DepartmentChip(
            department: department,
            isSelected: selectedDepartment?.id == department.id,
            onTap: () => onSelected(department),
          );
        },
      ),
    );
  }
}

class _DepartmentChip extends StatelessWidget {
  const _DepartmentChip({
    required this.department,
    required this.isSelected,
    required this.onTap,
  });

  final DepartmentEntity department;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${department.name} department',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 132,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  DepartmentIcons.forKey(department.iconKey),
                  size: 20,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
              Text(
                department.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
