import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/booking_model.dart';
import 'booking_details_screen.dart';

/// Success screen shown after a booking is confirmed and payment processed.
class BookingSuccessScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingSuccessScreen({super.key, required this.booking});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.booking;
    final dateFmt = DateFormat('EEE, MMM d • h:mm a');

    return PopScope(
      canPop: false, // prevent back-navigation into payment flow
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                // ── Animated success icon ─────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        size: 72, color: Color(0xFF2E7D32)),
                  ),
                ),

                const SizedBox(height: 28),

                Text('Booking Confirmed! ⚡',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center),

                const SizedBox(height: 10),
                Text(
                    'Your EV charging slot has been successfully reserved.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center),

                const SizedBox(height: 36),

                // ── Booking summary card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                          label: 'Booking ID',
                          value: '...${b.bookingId.substring(b.bookingId.length - 8).toUpperCase()}'),
                      _InfoRow(label: 'Station', value: b.stationName),
                      _InfoRow(
                          label: 'Time',
                          value: dateFmt.format(b.slotStartTime)),
                      _InfoRow(
                          label: 'Charger',
                          value: '${b.chargerType} · ${b.durationMinutes} min'),
                      _InfoRow(
                          label: 'Total Paid',
                          value: 'LKR ${b.totalAmount.toStringAsFixed(2)}',
                          valueColor: theme.colorScheme.primary),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Actions ───────────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(bookingId: b.bookingId)),
                  ),
                  icon: const Icon(Icons.confirmation_num_outlined),
                  label: const Text('View Booking',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: () => _launchMaps(b.stationName, b.stationAddress),
                  icon: const Icon(Icons.directions_outlined),
                  label: const Text('Navigate to Station',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Back to Home',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps(String name, String address) async {
    final encoded = Uri.encodeComponent('$name, $address');
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }
}
