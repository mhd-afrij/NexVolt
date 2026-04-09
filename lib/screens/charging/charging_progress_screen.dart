import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class ChargingProgressScreen extends StatefulWidget {
  const ChargingProgressScreen({super.key});

  @override
  State<ChargingProgressScreen> createState() => _ChargingProgressScreenState();
}

class _ChargingProgressScreenState extends State<ChargingProgressScreen> {
  double _progress = 0.56;

  void _boost() {
    setState(() {
      _progress = (_progress + 0.1).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_progress * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Charging Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Battery: $percentage%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _progress, minHeight: 10),
                  const SizedBox(height: 8),
                  const Text('Session energy: 8.7 kWh • Cost: LKR 592'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _boost,
            icon: const Icon(Icons.bolt),
            label: const Text('Refresh Progress'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.chargingComplete),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Stop Charging'),
          ),
        ],
      ),
    );
  }
}
