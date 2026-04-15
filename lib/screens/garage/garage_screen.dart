import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import '../../models/vehicle_model.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key, required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        Text(
          'Garage',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<VehicleModel>>(
          stream: repository.watchVehicles(),
          builder: (context, snapshot) {
            final vehicles = snapshot.data ?? const <VehicleModel>[];
            if (vehicles.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('No vehicles found.'),
                ),
              );
            }

            return Column(
              children: vehicles
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.electric_car),
                          title: Text(v.model),
                          subtitle: Text(v.plate),
                          trailing: Text('${v.batteryPercent}%'),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
