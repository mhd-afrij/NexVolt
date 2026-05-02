import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/vehicle_model.dart';
import '../providers/account_provider.dart';
import '../widgets/account_widgets.dart';
import '../widgets/shared_widgets.dart';
import 'add_edit_vehicle_screen.dart';

/// Lists all registered vehicles for the current user.
class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadVehicles();
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Vehicle'),
        content:
            Text('Remove ${vehicle.displayName} from your account?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AccountProvider>().deleteVehicle(vehicle.vehicleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Vehicle',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditVehicleScreen())),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.vehicles.isEmpty
              ? AccountEmptyState(
                  icon: Icons.electric_car_outlined,
                  title: 'No Vehicles Yet',
                  subtitle: 'Add your EV to get started with Nexvolt.',
                  action: FilledButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddEditVehicleScreen())),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Vehicle'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<AccountProvider>().loadVehicles(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.vehicles.length,
                    itemBuilder: (_, i) {
                      final v = provider.vehicles[i];
                      return VehicleCard(
                        vehicle: v,
                        onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddEditVehicleScreen(vehicle: v))),
                        onDelete: () => _confirmDelete(context, v),
                      );
                    },
                  ),
                ),
    );
  }
}
