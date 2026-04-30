import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an EV vehicle owned by a user, stored in Firestore [vehicles] collection.
class VehicleModel {
  final String vehicleId;
  final String userId;
  final String brand;             // e.g. 'Tesla'
  final String company;           // e.g. 'Tesla Motors'
  final String model;             // e.g. 'Model 3'
  final String vehicleType;       // 'Sedan' | 'SUV' | 'Hatchback' | 'Van' | 'Motorcycle'
  final double batteryCapacityKWh;
  final String connectorType;     // 'Type 1' | 'Type 2' | 'CCS' | 'CHAdeMO' | 'Tesla'
  final double currentBatteryPercentage; // 0–100
  final DateTime createdAt;

  const VehicleModel({
    required this.vehicleId,
    required this.userId,
    required this.brand,
    required this.company,
    required this.model,
    required this.vehicleType,
    required this.batteryCapacityKWh,
    required this.connectorType,
    required this.currentBatteryPercentage,
    required this.createdAt,
  });

  VehicleModel copyWith({
    String? vehicleId,
    String? userId,
    String? brand,
    String? company,
    String? model,
    String? vehicleType,
    double? batteryCapacityKWh,
    String? connectorType,
    double? currentBatteryPercentage,
    DateTime? createdAt,
  }) {
    return VehicleModel(
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      company: company ?? this.company,
      model: model ?? this.model,
      vehicleType: vehicleType ?? this.vehicleType,
      batteryCapacityKWh: batteryCapacityKWh ?? this.batteryCapacityKWh,
      connectorType: connectorType ?? this.connectorType,
      currentBatteryPercentage:
          currentBatteryPercentage ?? this.currentBatteryPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      vehicleId: map['vehicleId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      company: map['company'] as String? ?? '',
      model: map['model'] as String? ?? '',
      vehicleType: map['vehicleType'] as String? ?? '',
      batteryCapacityKWh: (map['batteryCapacityKWh'] as num?)?.toDouble() ?? 0.0,
      connectorType: map['connectorType'] as String? ?? '',
      currentBatteryPercentage:
          (map['currentBatteryPercentage'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'brand': brand,
      'company': company,
      'model': model,
      'vehicleType': vehicleType,
      'batteryCapacityKWh': batteryCapacityKWh,
      'connectorType': connectorType,
      'currentBatteryPercentage': currentBatteryPercentage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Display name combining brand and model.
  String get displayName => '$brand $model';
}
