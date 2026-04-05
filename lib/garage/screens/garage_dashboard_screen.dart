import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/garage_providers.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_details_screen.dart';

class GarageDashboardScreen extends ConsumerWidget {
  const GarageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsyncValue = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.slidersHorizontal, color: Colors.white),
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
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF00D1B2),
            backgroundColor: const Color(0xFF1A1A1A),
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
                    ref.read(selectedVehicleIdProvider.notifier).setId(vehicle.id);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const VehicleDetailsScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutBack;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  onLongPress: () {
                    // Show edit/delete bottom sheet
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D1B2)),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00D1B2),
        onPressed: () {
          // Add new vehicle
        },
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      /* Bottom Navigation omitted for scope, in parent module */
    );
  }
}
