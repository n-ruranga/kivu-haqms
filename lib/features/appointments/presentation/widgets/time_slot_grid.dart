import 'package:flutter/material.dart';
import 'package:kivu_haqms/core/constants/app_colors.dart';
import 'package:kivu_haqms/core/utils/date_format.dart';

/// Grid of `HH:mm` slots — step 4. Slots already booked are shown struck
/// through and cannot be tapped.
class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.bookedSlots,
    required this.selectedSlot,
    required this.onSelected,
  });

  final List<String> slots;
  final List<String> bookedSlots;
  final String? selectedSlot;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const _EmptySlots();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) {
        final isBooked = bookedSlots.contains(slot);
        final isSelected = slot == selectedSlot;

        return _SlotChip(
          slot: slot,
          isBooked: isBooked,
          isSelected: isSelected,
          onTap: isBooked ? null : () => onSelected(slot),
        );
      }).toList(),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  final String slot;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Color borderColor;

    if (isBooked) {
      background = AppColors.background;
      foreground = AppColors.textMuted;
      borderColor = AppColors.border;
    } else if (isSelected) {
      background = AppColors.primary;
      foreground = Colors.white;
      borderColor = AppColors.primary;
    } else {
      background = AppColors.surface;
      foreground = AppColors.textPrimary;
      borderColor = AppColors.border;
    }

    return Semantics(
      button: !isBooked,
      selected: isSelected,
      enabled: !isBooked,
      label: isBooked
          ? '${AppDateFormat.slotLabel(slot)}, already booked'
          : AppDateFormat.slotLabel(slot),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            AppDateFormat.slotLabel(slot),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foreground,
              decoration: isBooked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySlots extends StatelessWidget {
  const _EmptySlots();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            color: AppColors.textMuted,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            'No times left on this day.\nTry the next available date.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
