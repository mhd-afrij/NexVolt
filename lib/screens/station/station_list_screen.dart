import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import '../../models/station_model.dart';
import '../../routes/app_routes.dart';

class StationListScreen extends StatelessWidget {
  const StationListScreen({
    super.key,
    required this.repository,
    this.mainTabIndex = 0,
  });

  final AppRepository repository;
  final int mainTabIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stations')),
      body: StreamBuilder<List<StationModel>>(
        stream: repository.watchStations(),
        builder: (context, snapshot) {
          final stations = snapshot.data ?? const <StationModel>[];

          if (stations.isEmpty) {
            return const Center(child: Text('No stations available yet.'));
          }

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
