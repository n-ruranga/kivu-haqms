import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/theme/theme_colors.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

/// Selectable doctor row — step 2 of the booking form.
class DoctorOptionTile extends StatelessWidget {
  const DoctorOptionTile({
    super.key,
    required this.doctor,
    required this.isSelected,
    required this.onTap,
  });

  final DoctorEntity doctor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryTintBackground : context.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : context.primaryTintBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    doctor.initials,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primaryText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: context.mutedText,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            doctor.hospital,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
