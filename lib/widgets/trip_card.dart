import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip_plan_model.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  final TripPlan trip;
  final VoidCallback? onTap;

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'started':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'saved':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(trip.tripDate);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.route_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${trip.startLocationName} → ${trip.destinationName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(trip.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      trip.status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(trip.status),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 18),
                  const SizedBox(width: 6),
                  Text('${trip.distanceKm.toStringAsFixed(1)} km'),
                  const SizedBox(width: 16),
                  const Icon(Icons.battery_charging_full, size: 18),
                  const SizedBox(width: 6),
                  Text('${trip.estimatedBatteryRequired.toStringAsFixed(1)} kWh'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}