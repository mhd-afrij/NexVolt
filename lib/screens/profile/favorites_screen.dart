import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import '../../models/charging_session_model.dart';
import '../../models/station_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Charging'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stations'),
              Tab(text: 'Activity'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => repository.addChargingActivity(
                stationName: 'Tesla Station',
                energyKwh: 14.2,
              ),
              icon: const Icon(Icons.add),
              tooltip: 'Log activity',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            StreamBuilder<List<StationModel>>(
              stream: repository.watchFavoriteStations(),
              builder: (context, snapshot) {
                final stations = snapshot.data ?? const <StationModel>[];
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.ev_station),
                        title: Text(station.name),
                        subtitle: Text(station.address),
                        trailing: Text(
                          '${station.distanceKm.toStringAsFixed(1)} mi',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<List<ChargingSessionModel>>(
              stream: repository.watchChargingActivity(),
              builder: (context, snapshot) {
                final activities =
                    snapshot.data ?? const <ChargingSessionModel>[];
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final item = activities[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.stationName),
                        subtitle: Text(
                          item.timestamp.toLocal().toString().substring(0, 16),
                        ),
                        trailing: Text(
                          '${item.energyKwh.toStringAsFixed(1)} kWh',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
