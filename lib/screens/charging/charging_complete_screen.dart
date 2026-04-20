import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class ChargingCompleteScreen extends StatelessWidget {
  const ChargingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charging Complete')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ev_station, size: 72, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                'Session Finished Successfully',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text('Energy Delivered: 14.2 kWh'),
              const Text('Total Cost: LKR 966'),
              const Text('Duration: 42 minutes'),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.bookingHistory),
                child: const Text('View Booking History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
