import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Station Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              title: Text('GreenCharge Hub A'),
              subtitle: Text('Open 24/7 • 4 chargers available'),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Connector Types\n- CCS2\n- CHAdeMO\n- Type 2\n\nPricing\n- LKR 68 / kWh',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.reserveSlot),
            icon: const Icon(Icons.event_available),
            label: const Text('Reserve a Slot'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScanner),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Start Charging with QR'),
          ),
        ],
      ),
    );
  }
}
