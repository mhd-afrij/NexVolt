import '../models/vehicle.dart';
import '../models/timeline_event.dart';
import '../models/distance_log.dart';
import '../models/maintenance.dart';

class GarageRepository {
  // Simulating network delay
  Future<void> _delay() async => await Future.delayed(const Duration(milliseconds: 800));

  Future<List<Vehicle>> getVehicles() async {
    await _delay();
    return [
      const Vehicle(
        id: 'v1',
        name: 'Tesla Model X',
        plateNumber: 'NEX 1024',
        battery: 82.5,
        imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        location: 'Home Garage',
      ),
      const Vehicle(
        id: 'v2',
        name: 'Porsche Taycan',
        plateNumber: 'EV 9001',
        battery: 45.0,
        imageUrl: 'https://images.unsplash.com/photo-1614200187524-dc4b892acf16?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        location: 'Office Parking',
      ),
      const Vehicle(
        id: 'v3',
        name: 'Rivian R1T',
        plateNumber: 'RIV 4X4',
        battery: 15.0,
        imageUrl: 'https://images.unsplash.com/photo-1655075631721-a3f16ff3b9f3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        location: 'Charging Station',
      ),
    ];
  }

  Future<List<TimelineEvent>> getTimelineEvents(String vehicleId) async {
    await _delay();
    return [
      TimelineEvent(
        id: 't1',
        vehicleId: vehicleId,
        title: 'Tire Inspection',
        type: 'inspection',
        mileage: 15000,
        date: DateTime.now().add(const Duration(days: 5)),
        progress: 0.1,
      ),
      TimelineEvent(
        id: 't2',
        vehicleId: vehicleId,
        title: 'Supercharging',
        type: 'charge',
        mileage: 14800,
        date: DateTime.now().subtract(const Duration(days: 1)),
        progress: 1.0,
      ),
      TimelineEvent(
        id: 't3',
        vehicleId: vehicleId,
        title: 'Brake Fluid Check',
        type: 'maintenance',
        mileage: 10000,
        date: DateTime.now().subtract(const Duration(days: 30)),
        progress: 1.0,
      ),
    ];
  }

  Future<List<DistanceLog>> getDistanceLogs(String vehicleId) async {
    await _delay();
    final today = DateTime.now();
    return [
      DistanceLog(id: 'd1', vehicleId: vehicleId, date: today.subtract(const Duration(days: 6)), distance: 45),
      DistanceLog(id: 'd2', vehicleId: vehicleId, date: today.subtract(const Duration(days: 5)), distance: 12),
      DistanceLog(id: 'd3', vehicleId: vehicleId, date: today.subtract(const Duration(days: 4)), distance: 80),
      DistanceLog(id: 'd4', vehicleId: vehicleId, date: today.subtract(const Duration(days: 3)), distance: 65),
      DistanceLog(id: 'd5', vehicleId: vehicleId, date: today.subtract(const Duration(days: 2)), distance: 10),
      DistanceLog(id: 'd6', vehicleId: vehicleId, date: today.subtract(const Duration(days: 1)), distance: 0),
      DistanceLog(id: 'd7', vehicleId: vehicleId, date: today, distance: 30),
    ];
  }

  Future<List<MaintenanceRecord>> getMaintenanceRecords(String vehicleId) async {
    await _delay();
    return [
      MaintenanceRecord(
        id: 'm1',
        vehicleId: vehicleId,
        title: 'Annual Service',
        status: 'Upcoming',
        date: DateTime.now().add(const Duration(days: 45)),
      ),
      MaintenanceRecord(
        id: 'm2',
        vehicleId: vehicleId,
        title: 'Software Update 4.2',
        status: 'Completed',
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
      MaintenanceRecord(
        id: 'm3',
        vehicleId: vehicleId,
        title: 'Cabin Filter Replacement',
        status: 'Completed',
        date: DateTime.now().subtract(const Duration(days: 120)),
      ),
    ];
  }
}
