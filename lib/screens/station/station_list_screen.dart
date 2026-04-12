import 'package:flutter/material.dart';

import '../../models/station_model.dart';
import '../../routes/app_routes.dart';

class StationListScreen extends StatelessWidget {
  const StationListScreen({super.key, this.mainTabIndex = 0});

  final int mainTabIndex;

  @override
  Widget build(BuildContext context) {
    final stations = const [
      StationModel(
        id: 'greencharge-hub-a',
        name: 'GreenCharge Hub A',
        address: '2.1 km • Fast 150 kW',
        distanceKm: 2.1,
        latitude: 6.9271,
        longitude: 79.8612,
      ),
      StationModel(
        id: 'ev-park-central',
        name: 'EV Park Central',
        address: '4.6 km • Ultra 240 kW',
        distanceKm: 4.6,
        latitude: 6.92,
        longitude: 79.88,
      ),
      StationModel(
        id: 'highway-superport',
        name: 'Highway SuperPort',
        address: '9.8 km • Fast 120 kW',
        distanceKm: 9.8,
        latitude: 6.95,
        longitude: 79.9,
      ),
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
              title: Text(station.name),
              subtitle: Text(station.address),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.stationDetails,
                arguments: StationDetailsArgs(
                  station: station,
                  mainTabIndex: mainTabIndex,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
