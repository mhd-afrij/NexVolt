import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../widgets/trip_card.dart';

class TripPlannerScreen extends StatelessWidget {
  const TripPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleTrips = const [
      ('Office Commute', '42 km - 1 charging stop suggested'),
      ('Weekend Trip', '168 km - 2 charging stops suggested'),
      ('Airport Run', '58 km - No stop needed'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Trip Planner',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Plan routes, estimate charge, and review trip history.'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.planTrip),
                icon: const Icon(Icons.add_road),
                label: const Text('Plan New Trip'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.tripHistory),
                icon: const Icon(Icons.history),
                label: const Text('Trip History'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...sampleTrips.map(
          (trip) => TripCard(
            label: trip.$1,
            subtitle: trip.$2,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${trip.$1} details...')),
              );
            },
          ),
        ),
      ],
    );
  }
}
