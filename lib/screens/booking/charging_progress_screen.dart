import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking_model.dart';
import '../../data/models/charging_session_model.dart';
import '../providers/booking_provider.dart';

/// Shows live charging progress: percentage, energy, elapsed time.
/// For coursework, progress is simulated locally with a timer.
/// In production, listen to the Firestore `charging_sessions` document stream.
class ChargingProgressScreen extends StatefulWidget {
  final BookingModel booking;

  const ChargingProgressScreen({super.key, required this.booking});

  @override
  State<ChargingProgressScreen> createState() => _ChargingProgressScreenState();
}

class _ChargingProgressScreenState extends State<ChargingProgressScreen> {
  Timer? _simulationTimer;
  int _percentage = 0;
  double _kWh = 0.0;
  int _elapsedMinutes = 0;
  bool _stopped = false;

  // Simulation config — replace with Firestore stream for production
  static const _tickSeconds = 5; // simulate 1 min per 5 real seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<BookingProvider>();
      await prov.loadChargingSession(widget.booking.bookingId);
      // Seed from existing session if available
      final session = prov.currentChargingSession;
      if (session != null) {
        setState(() {
          _percentage = session.currentPercentage;
          _kWh = session.energyDeliveredKWh;
          _elapsedMinutes = session.durationMinutes;
        });
      }
      _startSimulation();
    });
  }

  void _startSimulation() {
    _simulationTimer =
        Timer.periodic(const Duration(seconds: _tickSeconds), (_) async {
      if (_stopped || _percentage >= 100) {
        _simulationTimer?.cancel();
        return;
      }
      setState(() {
        _percentage = (_percentage + 2).clamp(0, 100);
        _kWh += 0.24; // ~7.2kW / 30 ticks per hour
        _elapsedMinutes++;
      });

      final prov = context.read<BookingProvider>();
      await prov.updateChargingProgress(
        percentage: _percentage,
        kWh: _kWh,
        minutes: _elapsedMinutes,
      );

      if (_percentage >= 100) {
        _simulationTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  int get _estimatedRemainingMinutes {
    if (_percentage >= 100) return 0;
    final remaining = 100 - _percentage;
    // Assume 2% per tick, 1 minute per tick
    return remaining;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (_, __) => _simulationTimer?.cancel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Charging',
              style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: false,
          elevation: 0,
        ),
        body: Consumer<BookingProvider>(
          builder: (context, prov, _) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ── Station name ────────────────────────────────────────────
                Text(widget.booking.stationName,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center),
                Text(widget.booking.chargerType,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center),

                const SizedBox(height: 40),

                // ── Circular battery indicator ──────────────────────────────
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: _percentage / 100,
                            strokeWidth: 14,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            color: _percentage >= 80
                                ? const Color(0xFF2E7D32)
                                : theme.colorScheme.primary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_percentage%',
                                style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary)),
                            const Icon(Icons.bolt, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Stats grid ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                      label: 'Energy',
                      value: '${_kWh.toStringAsFixed(2)} kWh',
                      icon: Icons.electric_bolt,
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                      label: 'Elapsed',
                      value: '$_elapsedMinutes min',
                      icon: Icons.timer_outlined,
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                      label: 'Est. Remaining',
                      value: _percentage >= 100
                          ? 'Done!'
                          : '~$_estimatedRemainingMinutes min',
                      icon: Icons.hourglass_bottom_outlined,
                    )),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Charging status message ─────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    key: ValueKey(_percentage >= 100),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _percentage >= 100
                          ? const Color(0xFFE8F5E9)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _percentage >= 100
                              ? Icons.check_circle_rounded
                              : Icons.electric_bolt,
                          color: _percentage >= 100
                              ? const Color(0xFF2E7D32)
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _percentage >= 100
                              ? 'Charging complete! Your vehicle is ready.'
                              : 'Charging in progress… Please do not unplug.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Error ─────────────────────────────────────────────────
                if (prov.errorMessage != null)
                  Text(prov.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center),

                const SizedBox(height: 20),

                // ── Action buttons ─────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => _refreshProgress(prov),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Progress'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),

                const SizedBox(height: 10),

                if (_percentage < 100) ...[
                  OutlinedButton.icon(
                    onPressed: prov.isLoading ? null : () => _stopCharging(context, prov),
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: const Text('Stop Charging'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 10),
                ],

                FilledButton.icon(
                  onPressed: (_percentage >= 100 || _stopped) && !prov.isLoading
                      ? () => _completeSession(context, prov)
                      : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Complete',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _refreshProgress(BookingProvider prov) {
    prov.loadChargingSession(widget.booking.bookingId);
    final session = prov.currentChargingSession;
    if (session != null) {
      setState(() {
        _percentage = session.currentPercentage;
        _kWh = session.energyDeliveredKWh;
        _elapsedMinutes = session.durationMinutes;
      });
    }
  }

  Future<void> _stopCharging(BuildContext context, BookingProvider prov) async {
    _simulationTimer?.cancel();
    setState(() => _stopped = true);
    await prov.updateChargingProgress(
        percentage: _percentage, kWh: _kWh, minutes: _elapsedMinutes);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Charging stopped. Tap "Mark Complete" to finish.')),
      );
    }
  }

  Future<void> _completeSession(
      BuildContext context, BookingProvider prov) async {
    _simulationTimer?.cancel();
    final ok = await prov.completeCharging();
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session complete! Have a great trip ⚡')),
      );
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
