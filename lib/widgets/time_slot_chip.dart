import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/charger_model.dart';

/// A selectable time-slot chip shown in the slot picker grid.
class TimeSlotChip extends StatelessWidget {
  final BookingSlotModel slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('h:mm a');
    final unavailable = !slot.isAvailable;

    Color bgColor;
    Color fgColor;
    Color borderColor;

    if (unavailable) {
      bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.3);
      fgColor = theme.colorScheme.onSurface.withOpacity(0.3);
      borderColor = Colors.transparent;
    } else if (isSelected) {
      bgColor = theme.colorScheme.primary;
      fgColor = theme.colorScheme.onPrimary;
      borderColor = Colors.transparent;
    } else {
      bgColor = theme.colorScheme.surface;
      fgColor = theme.colorScheme.onSurface;
      borderColor = theme.colorScheme.outlineVariant;
    }

    return GestureDetector(
      onTap: unavailable ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(fmt.format(slot.startTime),
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: fgColor)),
            if (unavailable)
              Text('Booked',
                  style: TextStyle(fontSize: 9, color: fgColor, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
