
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_empty_state.dart';
import '../widgets/status_badge.dart';
import 'booking_details_screen.dart';
import 'reserve_slot_screen.dart';

/// Standalone booking history screen (also embedded as a tab in BookingScreen).
/// Shows completed and cancelled bookings with rebook shortcut.
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    const uid = 'default_user_001';
    await context.read<BookingProvider>().loadBookingHistory(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.historyBookings.isEmpty) {
            return RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  BookingEmptyState(
                    title: 'No booking history',
                    subtitle:
                        'Completed and cancelled sessions will show up here.',
                    icon: Icons.history,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: prov.historyBookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _HistoryCard(booking: prov.historyBookings[i]),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final BookingModel booking;

  const _HistoryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('EEE, MMM d · h:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  BookingDetailsScreen(bookingId: booking.bookingId)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ─────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: booking.bookingStatus == 'completed'
                      ? const Color(0xFFE8F5E9)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  booking.bookingStatus == 'completed'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 22,
                  color: booking.bookingStatus == 'completed'
                      ? const Color(0xFF2E7D32)
                      : theme.colorScheme.error,
                ),
              ),

              const SizedBox(width: 12),

              // ── Info ──────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.stationName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(dateFmt.format(booking.slotStartTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 3),
                    Text('${booking.chargerType} · ${booking.durationMinutes} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),

              // ── Right section ─────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: booking.bookingStatus),
                  const SizedBox(height: 8),
                  Text('LKR ${booking.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary)),
                  const SizedBox(height: 6),
                  // Rebook shortcut
                  if (booking.bookingStatus == 'completed')
                    GestureDetector(
                      onTap: () => _rebook(context),
                      child: Text('Rebook',
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to reserve slot screen pre-loading the same station.
  void _rebook(BuildContext context) {
    // Reset booking flow and push reservation with matching station
    context.read<BookingProvider>().resetBookingFlow();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReserveSlotScreen(
          station: StationModel(
            stationId: booking.stationId,
            name: booking.stationName,
            address: booking.stationAddress,
            latitude: 0,
            longitude: 0,
            availableSlots: 0,
            chargerTypes: [booking.chargerType],
            pricePerKWh: 0,
            isActive: true,
            imageUrl: '',
          ),
        ),
      ),
    );
  }
}
