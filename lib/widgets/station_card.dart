import 'package:flutter/material.dart';

import '../models/station_model.dart';

class StationCard extends StatelessWidget {
  const StationCard({super.key, required this.station});

  final StationModel station;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.ev_station),
        title: Text(station.name),
        subtitle: Text(station.address),
        trailing: Text('${station.distanceKm.toStringAsFixed(1)} mi'),
      ),
    );
  }
}
