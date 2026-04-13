import 'package:flutter/material.dart';

import '../models/station_model.dart';

class StationSuggestionCard extends StatelessWidget {
  const StationSuggestionCard({
    super.key,
    required this.station,
    this.onBookPressed,
  });

  final Station station;
  final VoidCallback? onBookPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Charging Station',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.ev_station),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Available slots: ${station.availableSlots}'),
            const SizedBox(height: 6),
            Text('Charger types: ${station.chargerTypes.join(', ')}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onBookPressed,
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Book Charger'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}