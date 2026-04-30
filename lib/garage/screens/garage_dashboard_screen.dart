import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../constants/app_colors.dart';
import '../models/vehicle.dart';
import '../viewmodels/garage_providers.dart';
import '../widgets/vehicle_card.dart';
import 'add_data_screen.dart';
import 'vehicle_details_screen.dart';

class GarageDashboardScreen extends ConsumerWidget {
  const GarageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsyncValue = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.slidersHorizontal,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              // Show filter
            },
          ),
        ],
      ),
      body: vehiclesAsyncValue.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(
              child: Text(
                'No vehicles found in your garage.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              return ref.refresh(vehiclesProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return VehicleCard(
                  vehicle: vehicle,
                  onTap: () {
                    ref
                        .read(selectedVehicleIdProvider.notifier)
                        .setId(vehicle.id);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const VehicleDetailsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutBack;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  onLongPress: () {
                    _showVehicleActions(context, ref, vehicle);
                  },
                  onEdit: () {
                    _showVehicleActions(context, ref, vehicle);
                  },
                  onDelete: () {
                    _confirmAndDeleteVehicle(context, ref, vehicle);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDataScreen()),
          );
        },
        child: const Icon(LucideIcons.plus, color: AppColors.textPrimary, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      /* Bottom Navigation omitted for scope, in parent module */
    );
  }

  Future<void> _showVehicleActions(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final repo = ref.read(garageRepositoryProvider);
    final nameController = TextEditingController(text: vehicle.name);
    final plateController = TextEditingController(text: vehicle.plateNumber);
    final batteryController = TextEditingController(
      text: vehicle.battery.toString(),
    );
    final locationController = TextEditingController(text: vehicle.location);
    final imageUrlController = TextEditingController(text: vehicle.imageUrl);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Vehicle',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: plateController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Plate Number',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: batteryController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Battery %',
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed < 0 || parsed > 100) {
                            return 'Enter 0-100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: locationController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: imageUrlController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final battery = double.parse(
                            batteryController.text.trim(),
                          );
                          await repo.updateVehicle(
                            id: vehicle.id,
                            name: nameController.text.trim(),
                            plateNumber: plateController.text.trim(),
                            battery: battery,
                            location: locationController.text.trim(),
                            imageUrl: imageUrlController.text.trim(),
                          );
                            if (!context.mounted) return;
                            ref.invalidate(vehiclesProvider);
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Vehicle updated successfully.'),
                                backgroundColor: AppColors.snackBarSuccess,
                              ),
                            );
                          Navigator.pop(context);
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          foregroundColor: AppColors.error,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: const Text(
                                  'Delete vehicle?',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                                content: const Text(
                                  'This will delete the vehicle from Firebase.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                           if (confirmed != true) return;
                          await repo.deleteVehicle(vehicle.id);
                          ref.invalidate(vehiclesProvider);
                          if (!context.mounted) return;
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Vehicle deleted.'),
                              backgroundColor: AppColors.snackBarError,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndDeleteVehicle(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final repo = ref.read(garageRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Delete vehicle?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'This will delete the vehicle from Firebase.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await repo.deleteVehicle(vehicle.id);
    ref.invalidate(vehiclesProvider);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Vehicle deleted.'),
        backgroundColor: AppColors.snackBarError,
      ),
    );
  }
}
