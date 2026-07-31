import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/theme/theme_colors.dart';
import 'package:kivu_haqms/features/doctors/domain/entities/doctor_entity.dart';

/// A doctor row on the "Find a Doctor" directory — tapping it starts a
/// booking with this doctor already chosen.
class DoctorListTile extends StatelessWidget {
  const DoctorListTile({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorEntity doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Book with ${doctor.fullName}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: context.cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.primaryTintBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    doctor.initials,
                    style: const TextStyle(
                      color: AppColors.primary,
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
              Icon(
                Icons.chevron_right_rounded,
                color: context.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
