import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/qr_booking_card.dart';
import '../widgets/status_badge.dart';
import 'charging_progress_screen.dart';
import 'qr_checkin_screen.dart';
import 'reschedule_booking_screen.dart';

/// Full booking detail view with QR, action buttons, and status-aware UI.
class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<BookingProvider>().loadBookingDetails(widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final booking = prov.currentBooking;
          if (booking == null) {
            return const Center(child: Text('Booking not found.'));
          }

          return RefreshIndicator(
            onRefresh: () =>
                prov.loadBookingDetails(widget.bookingId),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                // ── Status banner ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.stationName,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            Text(
                              DateFormat('EEE, MMM d · h:mm a')
                                  .format(booking.slotStartTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: booking.bookingStatus),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                BookingSummaryCard(booking: booking),

                // ── QR card — only for upcoming/started bookings ───────────
                if (booking.bookingStatus == BookingStatus.upcoming ||
                    booking.bookingStatus == BookingStatus.started) ...[
                  const SizedBox(height: 20),
                  QrBookingCard(booking: booking),
                ],

                const SizedBox(height: 20),

                // ── Error message ─────────────────────────────────────────
                if (prov.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(prov.errorMessage!,
                        style: TextStyle(
                            color: theme.colorScheme.onErrorContainer)),
                  ),
              ],
            ),
          );
        },
      ),

      // ── Bottom action buttons ────────────────────────────────────────────
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          final booking = prov.currentBooking;
          if (booking == null) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Navigate button — always visible
                  OutlinedButton.icon(
                    onPressed: () =>
                        _launchMaps(booking.stationName, booking.stationAddress),
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Navigate to Station'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // ── Cancel ────────────────────────────────────────────
                      if (booking.isCancellable)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: prov.isLoading
                                ? null
                                : () => _confirmCancel(context, prov, booking),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(
                                  color: theme.colorScheme.error
                                      .withOpacity(0.5)),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),

                      if (booking.isCancellable && booking.isReschedulable)
                        const SizedBox(width: 8),

                      // ── Reschedule ────────────────────────────────────────
                      if (booking.isReschedulable)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: prov.isLoading
                                ? null
                                : () => _goReschedule(context, booking),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reschedule',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),

                  // ── Start Charging / View Progress ─────────────────────
                  if (booking.bookingStatus == BookingStatus.upcoming) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: prov.isLoading
                          ? null
                          : () => _goToQrCheckin(context, booking),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Check-in & Start Charging',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                    ),
                  ],

                  if (booking.bookingStatus == BookingStatus.started) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChargingProgressScreen(
                                booking: booking)),
                      ),
                      icon: const Icon(Icons.bolt),
                      label: const Text('View Charging Progress',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext context, BookingProvider prov, BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final ok = await prov.cancelBooking(booking);
      if (ok && context.mounted) Navigator.pop(context);
    }
  }

  void _goReschedule(BuildContext context, BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => RescheduleBookingScreen(booking: booking)),
    );
  }

  void _goToQrCheckin(BuildContext context, BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => QrCheckinScreen(booking: booking)),
    );
  }

  Future<void> _launchMaps(String name, String address) async {
    final encoded = Uri.encodeComponent('$name, $address');
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
