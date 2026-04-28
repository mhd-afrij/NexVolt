import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip_plan_model.dart';

/// A compact card that displays a summary of a [TripPlanModel].
///
/// Used in both the Saved Trips tab and Trip History lists.
class TripCard extends StatelessWidget {
  final TripPlanModel trip;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Route row ──────────────────────────────────────────
              Row(
                children: [
                  _StatusBadge(status: trip.status),
                  const Spacer(),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: colorScheme.error.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _RouteLabel(
                from: trip.startLocationName,
                to: trip.destinationName,
              ),
              const SizedBox(height: 12),
              // ── Stats row ──────────────────────────────────────────
              Row(
                children: [
                  _StatChip(
                    icon: Icons.straighten_rounded,
                    label: '${trip.distanceKm.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: _formatDuration(trip.estimatedDurationMinutes),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.battery_charging_full_rounded,
                    label:
                        '${trip.batteryAtStart.toStringAsFixed(0)}% start',
                    color: _batteryColor(trip.batteryAtStart),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Date ──────────────────────────────────────────────
              Text(
                _formatDate(trip.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);

  Color _batteryColor(double percent) {
    if (percent >= 60) return const Color(0xFF34C759);
    if (percent >= 25) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }
}

// ── Internal sub-widgets ─────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  (String, Color) _resolve(String status) {
    switch (status) {
      case 'saved':
        return ('SAVED', const Color(0xFF007AFF));
      case 'started':
        return ('IN PROGRESS', const Color(0xFFFF9500));
      case 'completed':
        return ('COMPLETED', const Color(0xFF34C759));
      case 'cancelled':
        return ('CANCELLED', const Color(0xFFFF3B30));
      default:
        return (status.toUpperCase(), Colors.grey);
    }
  }
}

class _RouteLabel extends StatelessWidget {
  final String from;
  final String to;
  const _RouteLabel({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: onSurface.withOpacity(0.35),
              ),
              const SizedBox(height: 2),
              Text(
                to,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: onSurface.withOpacity(0.3),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _StatChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor =
        color ?? theme.colorScheme.onSurface.withOpacity(0.55);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
