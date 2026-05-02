import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/trip_plan_model.dart';
import '../providers/trip_provider.dart';
import '../widgets/battery_status_card.dart';
import '../widgets/route_summary_card.dart';

/// Shows all details of a saved trip with action buttons:
/// Start, Mark Completed, and Delete.
class SavedTripDetailsScreen extends StatefulWidget {
  final TripPlanModel trip;
  const SavedTripDetailsScreen({super.key, required this.trip});

  @override
  State<SavedTripDetailsScreen> createState() =>
      _SavedTripDetailsScreenState();
}

class _SavedTripDetailsScreenState extends State<SavedTripDetailsScreen> {
  // Local mutable copy for status updates.
  late TripPlanModel _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  Future<void> _startTrip() async {
    final provider = context.read<TripProvider>();
    await provider.startTrip(_trip.tripId);
    if (!mounted) return;
    setState(() => _trip = _trip.copyWith(status: 'started'));
    _showSuccess('Trip started!');
  }

  Future<void> _completeTrip() async {
    final provider = context.read<TripProvider>();
    await provider.completeTrip(_trip.tripId);
    if (!mounted) return;
    setState(() => _trip = _trip.copyWith(
          status: 'completed',
          completedAt: DateTime.now(),
        ));
    _showSuccess('Trip marked as completed!');
  }

  Future<void> _deleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text(
            'Are you sure you want to delete this trip? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TripProvider>().deleteTrip(_trip.tripId);
      if (mounted) Navigator.pop(context);
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openNavigation() async {
    final encoded = Uri.encodeComponent(_trip.destinationName);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<TripProvider>();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Trip Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Navigate button in app bar
          IconButton(
            icon: const Icon(Icons.navigation_rounded),
            tooltip: 'Navigate',
            onPressed: _openNavigation,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Status badge ────────────────────────────────────────────
          _StatusBanner(status: _trip.status),
          const SizedBox(height: 16),

          // ── Route summary ───────────────────────────────────────────
          RouteSummaryCard(
            from: _trip.startLocationName,
            to: _trip.destinationName,
            distanceKm: _trip.distanceKm,
            durationMinutes: _trip.estimatedDurationMinutes,
          ),
          const SizedBox(height: 16),

          // ── Battery summary ─────────────────────────────────────────
          BatteryStatusCard(
            batteryAtStart: _trip.batteryAtStart,
            batteryRequired: _trip.estimatedBatteryRequired,
            batteryRemaining: _trip.estimatedBatteryRemaining,
            needsChargingStop: _trip.needsChargingStop,
          ),
          const SizedBox(height: 16),

          // ── Charging station info (if applicable) ────────────────────
          if (_trip.recommendedStationName != null) ...[
            _StationInfoCard(
              stationName: _trip.recommendedStationName!,
              chargerType: _trip.selectedChargerType,
            ),
            const SizedBox(height: 16),
          ],

          // ── Metadata ────────────────────────────────────────────────
          _MetadataCard(trip: _trip),
          const SizedBox(height: 24),

          // ── Action buttons ──────────────────────────────────────────
          if (_trip.status == 'saved') ...[
            _ActionButton(
              label: 'Start Trip',
              icon: Icons.play_circle_rounded,
              color: const Color(0xFF007AFF),
              isLoading: provider.isLoading,
              onPressed: _startTrip,
            ),
            const SizedBox(height: 10),
          ],
          if (_trip.status == 'saved' || _trip.status == 'started') ...[
            _ActionButton(
              label: 'Mark as Completed',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF34C759),
              isLoading: provider.isLoading,
              onPressed: _completeTrip,
            ),
            const SizedBox(height: 10),
          ],
          _ActionButton(
            label: 'Delete Trip',
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFFF3B30),
            isLoading: provider.isLoading,
            onPressed: _deleteTrip,
            outlined: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _resolve(String status) {
    switch (status) {
      case 'saved':
        return ('Saved — ready to go', const Color(0xFF007AFF),
            Icons.bookmark_rounded);
      case 'started':
        return ('In Progress', const Color(0xFFFF9500),
            Icons.play_circle_rounded);
      case 'completed':
        return ('Completed', const Color(0xFF34C759),
            Icons.check_circle_rounded);
      case 'cancelled':
        return ('Cancelled', const Color(0xFFFF3B30), Icons.cancel_rounded);
      default:
        return (status, Colors.grey, Icons.info_outline_rounded);
    }
  }
}

class _StationInfoCard extends StatelessWidget {
  final String stationName;
  final String? chargerType;
  const _StationInfoCard(
      {required this.stationName, required this.chargerType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.ev_station_rounded,
              color: Color(0xFF007AFF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Charging Stop',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF007AFF).withOpacity(0.8),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stationName,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (chargerType != null)
                  Text(
                    chargerType!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  final TripPlanModel trip;
  const _MetadataCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _MetaRow(label: 'Trip ID', value: trip.tripId.substring(0, 8)),
          _MetaRow(label: 'Created', value: fmt.format(trip.createdAt)),
          if (trip.completedAt != null)
            _MetaRow(
                label: 'Completed', value: fmt.format(trip.completedAt!)),
          _MetaRow(
            label: 'Connector',
            value: trip.selectedChargerType ?? 'Any',
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? color : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
