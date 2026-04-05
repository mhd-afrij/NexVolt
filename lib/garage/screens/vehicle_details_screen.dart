import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../viewmodels/garage_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/timeline_item.dart';
import '../widgets/chart_widget.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  const VehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(selectedVehicleProvider);
    
    if (vehicle == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: Text("Vehicle not found", style: TextStyle(color: Colors.white))),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            vehicle.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Top Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Hero(
                      tag: 'vehicle_img_${vehicle.id}',
                      child: Image.network(
                        vehicle.imageUrl,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, _, __) => const Icon(LucideIcons.car, color: Colors.white54, size: 80),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.plateNumber,
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(LucideIcons.mapPin, color: Colors.white54, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle.location,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: vehicle.battery > 50 
                                ? const Color(0xFF00D1B2).withOpacity(0.2) 
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: vehicle.battery > 50 ? const Color(0xFF00D1B2) : Colors.orange,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.batteryCharging, 
                                color: vehicle.battery > 50 ? const Color(0xFF00D1B2) : Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${vehicle.battery.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: vehicle.battery > 50 ? const Color(0xFF00D1B2) : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            const TabBar(
              isScrollable: true,
              labelColor: Color(0xFF00D1B2),
              unselectedLabelColor: Colors.white54,
              indicatorColor: Color(0xFF00D1B2),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: "Timeline"),
                Tab(text: "Reports"),
                Tab(text: "Distance"),
                Tab(text: "Maintenance"),
              ],
            ),
            const SizedBox(height: 16),
            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _TimelineTab(vehicleId: vehicle.id),
                  _ReportsTab(vehicleId: vehicle.id),
                  _DistanceTab(vehicleId: vehicle.id),
                  _MaintenanceTab(vehicleId: vehicle.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends ConsumerWidget {
  final String vehicleId;
  const _TimelineTab({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(timelineEventsProvider(vehicleId));
    
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) return const Center(child: Text("No events", style: TextStyle(color: Colors.white54)));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return TimelineItemWidget(
              event: events[index],
              isLast: index == events.length - 1,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2))),
      error: (e, st) => Center(child: Text("Error loading timeline", style: TextStyle(color: Colors.red))),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final String vehicleId;
  const _ReportsTab({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    // Scaffold UI Mock for Reports
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(LucideIcons.activity, color: Colors.blueAccent),
                      SizedBox(height: 8),
                      Text("Total Trips", style: TextStyle(color: Colors.white54)),
                      SizedBox(height: 4),
                      Text("142", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(LucideIcons.zap, color: Colors.orange),
                      SizedBox(height: 8),
                      Text("Energy Usage", style: TextStyle(color: Colors.white54)),
                      SizedBox(height: 4),
                      Text("384 kWh", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Efficiency Score", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D1B2)),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                const Text("Great! Your efficiency is above average.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DistanceTab extends ConsumerWidget {
  final String vehicleId;
  const _DistanceTab({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(distanceLogsProvider(vehicleId));
    
    return logsAsync.when(
      data: (logs) {
        final totalDistance = logs.fold<double>(0, (prev, log) => prev + log.distance);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Distance (7 Days)", style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 4),
                        Text(
                          "${totalDistance.toStringAsFixed(1)} km",
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00D1B2).withOpacity(0.2)),
                      child: const Icon(LucideIcons.map, color: Color(0xFF00D1B2)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Daily Logs", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: DistanceChartWidget(logs: logs),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2))),
      error: (e, st) => Center(child: Text("Error loading distances", style: TextStyle(color: Colors.red))),
    );
  }
}

class _MaintenanceTab extends ConsumerWidget {
  final String vehicleId;
  const _MaintenanceTab({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(maintenanceRecordsProvider(vehicleId));
    
    return recordsAsync.when(
      data: (records) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = records[index];
            final isUpcoming = record.status.toLowerCase() == 'upcoming';
            
            return GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUpcoming ? Colors.orange.withOpacity(0.2) : const Color(0xFF00D1B2).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.wrench, 
                      color: isUpcoming ? Colors.orange : const Color(0xFF00D1B2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM d, yyyy').format(record.date),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isUpcoming ? Colors.orange : const Color(0xFF00D1B2),
                      ),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        color: isUpcoming ? Colors.orange : const Color(0xFF00D1B2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2))),
      error: (e, st) => Center(child: Text("Error loading maintenance", style: TextStyle(color: Colors.red))),
    );
  }
}
