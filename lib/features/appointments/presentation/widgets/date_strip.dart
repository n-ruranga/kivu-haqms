import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/theme/theme_colors.dart';
import 'package:kivu_haqms/core/utils/date_format.dart';

/// Horizontal strip of the doctor's next working days — step 3.
class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelected;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              selectedDate != null && _isSameDay(date, selectedDate!);

          return Semantics(
            button: true,
            selected: isSelected,
            label: AppDateFormat.fullDate(date),
            child: InkWell(
              onTap: () => onSelected(date),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 62,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : context.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : context.cardBorder,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppDateFormat.weekdayShort(date),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white70
                            : context.mutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppDateFormat.monthShort(date),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white70
                            : context.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
