import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/booking_model.dart';

/// A detailed booking summary card used on the summary & detail screens.
class BookingSummaryCard extends StatelessWidget {
  final BookingModel booking;

  const BookingSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('EEEE, MMMM d, y');
    final timeFmt = DateFormat('h:mm a');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(icon: Icons.ev_station, label: 'Station', value: booking.stationName),
            _Row(icon: Icons.location_on_outlined, label: 'Address', value: booking.stationAddress),
            _Row(icon: Icons.directions_car_outlined, label: 'Vehicle', value: booking.vehicleName),
            _Row(icon: Icons.bolt, label: 'Charger Type', value: booking.chargerType),
            _Row(icon: Icons.calendar_today_outlined, label: 'Date', value: dateFmt.format(booking.slotStartTime)),
            _Row(
              icon: Icons.access_time,
              label: 'Time',
              value:
                  '${timeFmt.format(booking.slotStartTime)} – ${timeFmt.format(booking.slotEndTime)}',
            ),
            _Row(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: '${booking.durationMinutes} min',
            ),
            const Divider(height: 24),
            _Row(
              icon: Icons.attach_money,
              label: 'Amount',
              value: 'LKR ${booking.amount.toStringAsFixed(2)}',
            ),
            _Row(
              icon: Icons.receipt_outlined,
              label: 'Tax (8%)',
              value: 'LKR ${booking.tax.toStringAsFixed(2)}',
            ),
            const Divider(height: 16),
            Row(
              children: [
                Text('Total',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(
                  'LKR ${booking.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
