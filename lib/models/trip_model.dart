import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_stop_model.dart';

/// Status enum for a trip.
enum TripStatus { planned, active, completed, cancelled }

extension TripStatusExt on TripStatus {
  String get value {
    switch (this) {
      case TripStatus.planned:
        return 'planned';
      case TripStatus.active:
        return 'active';
      case TripStatus.completed:
        return 'completed';
      case TripStatus.cancelled:
        return 'cancelled';
    }
  }

  static TripStatus fromString(String? s) {
    switch (s) {
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.planned;
    }
  }

  String get label {
    switch (this) {
      case TripStatus.planned:
        return 'Planned';
      case TripStatus.active:
        return 'Active';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Represents a complete planned EV trip stored in Firestore.
class TripModel {
  final String id;
  final String startLocation;
  final String destination;
  final DateTime tripDate;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final int batteryStart; // 0–100 %
  final int estimatedBatteryRequired; // 0–100 %
  final TripStatus status;
  final List<TripStopModel> chargingStops;
  final String vehicleId;
  final String vehicleDisplayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.startLocation,
    required this.destination,
    required this.tripDate,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.batteryStart,
    required this.estimatedBatteryRequired,
    required this.status,
    required this.chargingStops,
    required this.vehicleId,
    required this.vehicleDisplayName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasBatteryWarning => batteryStart < estimatedBatteryRequired && chargingStops.isEmpty;

  bool get isUpcoming =>
      status == TripStatus.planned &&
      tripDate.isAfter(DateTime.now());

  bool get isPast =>
      status == TripStatus.completed ||
      status == TripStatus.cancelled ||
      (status == TripStatus.planned && tripDate.isBefore(DateTime.now()));

  int get estimatedArrivalBattery {
    final used = estimatedBatteryRequired;
    final charged = chargingStops.fold<int>(
        0, (sum, s) => sum + s.chargeAddedPercent);
    return (batteryStart - used + charged).clamp(0, 100);
  }

  TripModel copyWith({
    String? id,
    String? startLocation,
    String? destination,
    DateTime? tripDate,
    double? distanceKm,
    int? estimatedDurationMinutes,
    int? batteryStart,
    int? estimatedBatteryRequired,
    TripStatus? status,
    List<TripStopModel>? chargingStops,
    String? vehicleId,
    String? vehicleDisplayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      destination: destination ?? this.destination,
      tripDate: tripDate ?? this.tripDate,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      batteryStart: batteryStart ?? this.batteryStart,
      estimatedBatteryRequired:
          estimatedBatteryRequired ?? this.estimatedBatteryRequired,
      status: status ?? this.status,
      chargingStops: chargingStops ?? this.chargingStops,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleDisplayName: vehicleDisplayName ?? this.vehicleDisplayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TripModel.fromMap(String docId, Map<String, dynamic> map) {
    final stopsRaw = map['chargingStops'] as List<dynamic>? ?? [];
    return TripModel(
      id: docId,
      startLocation: map['startLocation'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      tripDate: (map['tripDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMinutes:
          (map['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      batteryStart: (map['batteryStart'] as num?)?.toInt() ?? 100,
      estimatedBatteryRequired:
          (map['estimatedBatteryRequired'] as num?)?.toInt() ?? 0,
      status: TripStatusExt.fromString(map['status'] as String?),
      chargingStops: stopsRaw
          .map((e) => TripStopModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      vehicleId: map['vehicleId'] as String? ?? '',
      vehicleDisplayName: map['vehicleDisplayName'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startLocation': startLocation,
      'destination': destination,
      'tripDate': Timestamp.fromDate(tripDate),
      'distanceKm': distanceKm,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'batteryStart': batteryStart,
      'estimatedBatteryRequired': estimatedBatteryRequired,
      'status': status.value,
      'chargingStops': chargingStops.map((s) => s.toMap()).toList(),
      'vehicleId': vehicleId,
      'vehicleDisplayName': vehicleDisplayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get formattedDistance => '${distanceKm.toStringAsFixed(0)} km';

  String get formattedDuration {
    final h = estimatedDurationMinutes ~/ 60;
    final m = estimatedDurationMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
