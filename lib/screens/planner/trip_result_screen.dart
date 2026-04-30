import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/trip_provider.dart';
import '../widgets/battery_status_card.dart';
import '../widgets/route_summary_card.dart';
import '../widgets/station_suggestion_card.dart';

/// Displays the result of a trip calculation:
/// route info, battery summary, and optional charging station.
class TripResultScreen extends StatelessWidget {
  const TripResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Trip Result',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Route summary ───────────────────────────────────────────
          RouteSummaryCard(
            from: provider.startLocationName,
            to: provider.destinationName,
            distanceKm: provider.routeDistanceKm,
            durationMinutes: provider.estimatedDurationMinutes,
          ),
          const SizedBox(height: 16),

          // ── Battery summary ─────────────────────────────────────────
          BatteryStatusCard(
            batteryAtStart:
                provider.selectedVehicle?.currentBatteryPercentage ?? 0,
            batteryRequired: provider.batteryRequired,
            batteryRemaining: provider.batteryRemaining,
            needsChargingStop: provider.needsChargingStop,
          ),
          const SizedBox(height: 16),

          // ── Station recommendation / all-clear ──────────────────────
          if (provider.needsChargingStop) ...[
            if (provider.recommendedStation != null)
              StationSuggestionCard(
                station: provider.recommendedStation!,
                onBookCharger: () => _navigateToBookCharger(
                  context,
                  provider.recommendedStation!.stationId,
                ),
              )
            else
              _NoStationWarning(),
            const SizedBox(height: 16),
          ] else
            _AllClearBanner(),

          const SizedBox(height: 8),

          // ── Action buttons ──────────────────────────────────────────
          _SaveTripButton(provider: provider),
          const SizedBox(height: 12),
          _StartNavigationButton(
            destinationLat:
                provider.destinationLatLng?.latitude ?? 0,
            destinationLng:
                provider.destinationLatLng?.longitude ?? 0,
            destinationName: provider.destinationName,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// ⚠️ INTEGRATION HOOK — replace with your actual booking navigation.
  void _navigateToBookCharger(BuildContext context, String stationId) {
    // TODO: Navigate to the booking module and pass [stationId].
    // Example: Navigator.pushNamed(context, '/booking', arguments: stationId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking module — station: $stationId'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _AllClearBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF34C759).withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF34C759).withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle_rounded, color: Color(0xFF34C759), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery Sufficient',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF34C759),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your battery is enough for this trip. No charging stop needed.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF34C759),
                    fontWeight: FontWeight.w400,
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

class _NoStationWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFFF9500).withOpacity(0.25), width: 1.2),
      ),
      child: Row(
        children: const [
          Icon(Icons.ev_station_outlined, color: Color(0xFFFF9500), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Charging Station Found',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFFFF9500),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A charging stop is needed but no suitable active station was found along this route. Consider choosing a different route or connector type.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF9500),
                    fontWeight: FontWeight.w400,
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

class _SaveTripButton extends StatefulWidget {
  final TripProvider provider;
  const _SaveTripButton({required this.provider});

  @override
  State<_SaveTripButton> createState() => _SaveTripButtonState();
}

class _SaveTripButtonState extends State<_SaveTripButton> {
  bool _saved = false;

  Future<void> _save() async {
    final trip = await widget.provider.saveTrip();
    if (!mounted) return;
    if (trip != null) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip saved successfully!'),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(widget.provider.errorMessage ?? 'Failed to save trip.'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_saved) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: Color(0xFF34C759), size: 20),
            SizedBox(width: 8),
            Text(
              'Trip Saved',
              style: TextStyle(
                color: Color(0xFF34C759),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: widget.provider.isLoading ? null : _save,
        icon: const Icon(Icons.bookmark_add_rounded, size: 18),
        label: const Text(
          'Save Trip',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: const Color.fromARGB(255, 68, 60, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _StartNavigationButton extends StatelessWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationName;

  const _StartNavigationButton({
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
  });

  Future<void> _openGoogleMaps(BuildContext context) async {
    // Deep-link to Google Maps navigation.
    final encodedDest = Uri.encodeComponent(destinationName);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$encodedDest'
      '&destination_place_id=&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: coordinates-based URL
      final fallback = Uri.parse(
        'https://maps.google.com/?daddr=$destinationLat,$destinationLng',
      );
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _openGoogleMaps(context),
        icon: const Icon(Icons.navigation_rounded, size: 18),
        label: const Text(
          'Start Navigation',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
