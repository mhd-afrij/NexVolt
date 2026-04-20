import 'package:flutter/material.dart';

import '../models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.electric_car),
        title: Text(vehicle.model),
        subtitle: Text(vehicle.plate),
        trailing: Text('${vehicle.batteryPercent}%'),
      ),
    );
  }
}
