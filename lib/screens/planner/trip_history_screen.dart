import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/trip_plan_model.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_empty_state.dart';

/// Displays a list of completed trips grouped by status.
/// Accessible as the "Trip History" tab within [TripPlannerScreen].
class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.historyTrips.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.historyTrips.isEmpty) {
          return const TripEmptyState(
            icon: Icons.history_rounded,
            title: 'No Trip History',
            subtitle:
                'Completed trips will appear here. Start a saved trip and mark it complete.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadTripHistory,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: provider.historyTrips.length,
            itemBuilder: (context, index) {
              return _HistoryTripCard(
                  trip: provider.historyTrips[index]);
            },
          ),
        );
      },
    );
  }
}

// ── History Trip Card ─────────────────────────────────────────────────────

class _HistoryTripCard extends StatelessWidget {
  final TripPlanModel trip;
  const _HistoryTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: route + date ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.startLocationName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.arrow_downward_rounded,
                      size: 14,
                      color: Color(0xFF8E8E93),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.destinationName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Completed badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'COMPLETED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34C759),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stats ────────────────────────────────────────────────
          Row(
            children: [
              _HistoryStat(
                icon: Icons.straighten_rounded,
                label: '${trip.distanceKm.toStringAsFixed(1)} km',
              ),
              const SizedBox(width: 8),
              _HistoryStat(
                icon: Icons.timer_outlined,
                label: _formatDuration(trip.estimatedDurationMinutes),
              ),
              const SizedBox(width: 8),
              _HistoryStat(
                icon: trip.needsChargingStop
                    ? Icons.ev_station_rounded
                    : Icons.battery_charging_full_rounded,
                label: trip.needsChargingStop ? 'Charged' : 'No stop',
                color: trip.needsChargingStop
                    ? const Color(0xFF007AFF)
                    : const Color(0xFF34C759),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Dates ────────────────────────────────────────────────
          if (trip.completedAt != null)
            Text(
              'Completed ${DateFormat('dd MMM yyyy, HH:mm').format(trip.completedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _HistoryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _HistoryStat({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor =
        color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
