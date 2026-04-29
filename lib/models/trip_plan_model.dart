import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a saved or historical trip plan for an EV user.
class TripPlanModel {
  final String tripId;
  final String userId;
  final String vehicleId;
  final String startLocationName;
  final String destinationName;
  final double startLatitude;
  final double startLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final double batteryAtStart; // percentage (0–100)
  final double estimatedBatteryRequired; // percentage
  final double estimatedBatteryRemaining; // percentage
  final bool needsChargingStop;
  final String? recommendedStationId;
  final String? recommendedStationName;
  final String? selectedChargerType;
  final String status; // saved | started | completed | cancelled
  final DateTime createdAt;
  final DateTime? tripDate;
  final DateTime? completedAt;

  const TripPlanModel({
    required this.tripId,
    required this.userId,
    required this.vehicleId,
    required this.startLocationName,
    required this.destinationName,
    required this.startLatitude,
    required this.startLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.batteryAtStart,
    required this.estimatedBatteryRequired,
    required this.estimatedBatteryRemaining,
    required this.needsChargingStop,
    this.recommendedStationId,
    this.recommendedStationName,
    this.selectedChargerType,
    required this.status,
    required this.createdAt,
    this.tripDate,
    this.completedAt,
  });

  /// Creates a copy of this model with optional field overrides.
  TripPlanModel copyWith({
    String? tripId,
    String? userId,
    String? vehicleId,
    String? startLocationName,
    String? destinationName,
    double? startLatitude,
    double? startLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    double? distanceKm,
    int? estimatedDurationMinutes,
    double? batteryAtStart,
    double? estimatedBatteryRequired,
    double? estimatedBatteryRemaining,
    bool? needsChargingStop,
    String? recommendedStationId,
    String? recommendedStationName,
    String? selectedChargerType,
    String? status,
    DateTime? createdAt,
    DateTime? tripDate,
    DateTime? completedAt,
  }) {
    return TripPlanModel(
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      startLocationName: startLocationName ?? this.startLocationName,
      destinationName: destinationName ?? this.destinationName,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      batteryAtStart: batteryAtStart ?? this.batteryAtStart,
      estimatedBatteryRequired:
          estimatedBatteryRequired ?? this.estimatedBatteryRequired,
      estimatedBatteryRemaining:
          estimatedBatteryRemaining ?? this.estimatedBatteryRemaining,
      needsChargingStop: needsChargingStop ?? this.needsChargingStop,
      recommendedStationId: recommendedStationId ?? this.recommendedStationId,
      recommendedStationName:
          recommendedStationName ?? this.recommendedStationName,
      selectedChargerType: selectedChargerType ?? this.selectedChargerType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      tripDate: tripDate ?? this.tripDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Deserialises a Firestore document snapshot into [TripPlanModel].
  factory TripPlanModel.fromMap(Map<String, dynamic> map) {
    return TripPlanModel(
      tripId: map['tripId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      vehicleId: map['vehicleId'] as String? ?? '',
      startLocationName: map['startLocationName'] as String? ?? '',
      destinationName: map['destinationName'] as String? ?? '',
      startLatitude: (map['startLatitude'] as num?)?.toDouble() ?? 0.0,
      startLongitude: (map['startLongitude'] as num?)?.toDouble() ?? 0.0,
      destinationLatitude:
          (map['destinationLatitude'] as num?)?.toDouble() ?? 0.0,
      destinationLongitude:
          (map['destinationLongitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMinutes:
          (map['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      batteryAtStart: (map['batteryAtStart'] as num?)?.toDouble() ?? 0.0,
      estimatedBatteryRequired:
          (map['estimatedBatteryRequired'] as num?)?.toDouble() ?? 0.0,
      estimatedBatteryRemaining:
          (map['estimatedBatteryRemaining'] as num?)?.toDouble() ?? 0.0,
      needsChargingStop: map['needsChargingStop'] as bool? ?? false,
      recommendedStationId: map['recommendedStationId'] as String?,
      recommendedStationName: map['recommendedStationName'] as String?,
      selectedChargerType: map['selectedChargerType'] as String?,
      status: map['status'] as String? ?? 'saved',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tripDate: (map['tripDate'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serialises this model to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'vehicleId': vehicleId,
      'startLocationName': startLocationName,
      'destinationName': destinationName,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'distanceKm': distanceKm,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'batteryAtStart': batteryAtStart,
      'estimatedBatteryRequired': estimatedBatteryRequired,
      'estimatedBatteryRemaining': estimatedBatteryRemaining,
      'needsChargingStop': needsChargingStop,
      'recommendedStationId': recommendedStationId,
      'recommendedStationName': recommendedStationName,
      'selectedChargerType': selectedChargerType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'tripDate': tripDate != null ? Timestamp.fromDate(tripDate!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  @override
  String toString() => 'TripPlanModel(tripId: $tripId, status: $status, '
      'from: $startLocationName, to: $destinationName)';
}
