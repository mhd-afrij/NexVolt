import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class StationListScreen extends StatelessWidget {
  const StationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stations = const [
      ('GreenCharge Hub A', '2.1 km', 'Fast 150 kW'),
      ('EV Park Central', '4.6 km', 'Ultra 240 kW'),
      ('Highway SuperPort', '9.8 km', 'Fast 120 kW'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stations')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          return Card(
            child: ListTile(
              title: Text(station.$1),
              subtitle: Text('${station.$2} • ${station.$3}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.stationDetails),
            ),
          );
        },
      ),
    );
  }
}
