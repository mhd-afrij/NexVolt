import 'package:flutter/material.dart';
import '../models/timeline_event.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

class TimelineItemWidget extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const TimelineItemWidget({
    super.key,
    required this.event,
    this.isLast = false,
  });

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'inspection':
        return LucideIcons.clipboardCheck;
      case 'oil':
        return LucideIcons.droplet;
      case 'charge':
        return LucideIcons.zap;
      case 'maintenance':
        return LucideIcons.wrench;
      default:
        return LucideIcons.calendar;
    }
  }

  Color _getColorForProgress(double progress) {
    if (progress >= 1.0) return AppColors.accent;
    if (progress >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForProgress(event.progress);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vertical Line and Node
          SizedBox(
            width: 50,
            child: Column(
              children: [
                 Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                       color: color.withValues(alpha: 0.2),
                      border: Border.all(color: color, width: 2),
                    ),
                  child: Icon(
                    _getIconForType(event.type),
                    size: 16,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(event.date),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                      Text(
                        '${NumberFormat.decimalPattern().format(event.mileage)} km',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: event.progress,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(event.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
