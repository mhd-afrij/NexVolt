import 'package:cloud_firestore/cloud_firestore.dart';

class TripPlan {
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
  final double batteryAtStart;
  final double estimatedBatteryRequired;
  final double estimatedBatteryRemaining;
  final bool needsChargingStop;
  final String? recommendedStationId;
  final String? recommendedStationName;
  final String? selectedChargerType;
  final String status;
  final DateTime createdAt;
  final DateTime tripDate;
  final DateTime? completedAt;

  TripPlan({
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
    required this.tripDate,
    this.completedAt,
  });

  factory TripPlan.fromMap(Map<String, dynamic> map) {
    return TripPlan(
      tripId: map['tripId'],
      userId: map['userId'],
      vehicleId: map['vehicleId'],
      startLocationName: map['startLocationName'],
      destinationName: map['destinationName'],
      startLatitude: map['startLatitude'],
      startLongitude: map['startLongitude'],
      destinationLatitude: map['destinationLatitude'],
      destinationLongitude: map['destinationLongitude'],
      distanceKm: map['distanceKm'],
      estimatedDurationMinutes: map['estimatedDurationMinutes'],
      batteryAtStart: map['batteryAtStart'],
      estimatedBatteryRequired: map['estimatedBatteryRequired'],
      estimatedBatteryRemaining: map['estimatedBatteryRemaining'],
      needsChargingStop: map['needsChargingStop'],
      recommendedStationId: map['recommendedStationId'],
      recommendedStationName: map['recommendedStationName'],
      selectedChargerType: map['selectedChargerType'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      tripDate: (map['tripDate'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

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
      'tripDate': Timestamp.fromDate(tripDate),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  TripPlan copyWith({String? status}) {
    return TripPlan(
      tripId: tripId,
      userId: userId,
      vehicleId: vehicleId,
      startLocationName: startLocationName,
      destinationName: destinationName,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      distanceKm: distanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes,
      batteryAtStart: batteryAtStart,
      estimatedBatteryRequired: estimatedBatteryRequired,
      estimatedBatteryRemaining: estimatedBatteryRemaining,
      needsChargingStop: needsChargingStop,
      recommendedStationId: recommendedStationId,
      recommendedStationName: recommendedStationName,
      selectedChargerType: selectedChargerType,
      status: status ?? this.status,
      createdAt: createdAt,
      tripDate: tripDate,
      completedAt: completedAt,
    );
  }
}