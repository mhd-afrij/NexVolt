import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/garage_repository.dart';
import '../models/vehicle.dart';
import '../models/timeline_event.dart';
import '../models/distance_log.dart';
import '../models/maintenance.dart';

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepository();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repo = ref.read(garageRepositoryProvider);
  return repo.getVehicles();
});

class SelectedVehicleIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setId(String? id) => state = id;
}

final selectedVehicleIdProvider = NotifierProvider<SelectedVehicleIdNotifier, String?>(SelectedVehicleIdNotifier.new);

final selectedVehicleProvider = Provider<Vehicle?>((ref) {
  final vehiclesOpt = ref.watch(vehiclesProvider).value;
  final selectedId = ref.watch(selectedVehicleIdProvider);
  if (vehiclesOpt == null || selectedId == null) return null;
  return vehiclesOpt.firstWhere(
    (v) => v.id == selectedId,
    orElse: () => vehiclesOpt.first,
  );
});

final timelineEventsProvider = FutureProvider.family<List<TimelineEvent>, String>((ref, vehicleId) async {
  final repo = ref.read(garageRepositoryProvider);
  return repo.getTimelineEvents(vehicleId);
});

final distanceLogsProvider = FutureProvider.family<List<DistanceLog>, String>((ref, vehicleId) async {
  final repo = ref.read(garageRepositoryProvider);
  return repo.getDistanceLogs(vehicleId);
});

final maintenanceRecordsProvider = FutureProvider.family<List<MaintenanceRecord>, String>((ref, vehicleId) async {
  final repo = ref.read(garageRepositoryProvider);
  return repo.getMaintenanceRecords(vehicleId);
});
