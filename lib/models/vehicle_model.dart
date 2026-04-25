import 'package:cloud_firestore/cloud_firestore.dart';

/// Minimal vehicle model used within the Trip Planner feature.
/// The full vehicle module may extend this.
class VehicleModel {
  final String vehicleId;
  final String userId;
  final String brand;
  final String model;
  final double batteryCapacityKWh;
  final double currentBatteryPercentage; // 0–100
  final String connectorType; // e.g. "Type2", "CCS", "CHAdeMO"
  final double efficiencyWhPerKm; // energy used per km in Wh

  const VehicleModel({
    required this.vehicleId,
    required this.userId,
    required this.brand,
    required this.model,
    required this.batteryCapacityKWh,
    required this.currentBatteryPercentage,
    required this.connectorType,
    required this.efficiencyWhPerKm,
  });

  /// Convenience getter: display name shown in dropdowns.
  String get displayName => '$brand $model';

  /// Efficiency in kWh per km (converted from Wh/km).
  double get efficiencyKWhPerKm => efficiencyWhPerKm / 1000.0;

  VehicleModel copyWith({
    String? vehicleId,
    String? userId,
    String? brand,
    String? model,
    double? batteryCapacityKWh,
    double? currentBatteryPercentage,
    String? connectorType,
    double? efficiencyWhPerKm,
  }) {
    return VehicleModel(
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      batteryCapacityKWh: batteryCapacityKWh ?? this.batteryCapacityKWh,
      currentBatteryPercentage:
          currentBatteryPercentage ?? this.currentBatteryPercentage,
      connectorType: connectorType ?? this.connectorType,
      efficiencyWhPerKm: efficiencyWhPerKm ?? this.efficiencyWhPerKm,
    );
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      vehicleId: map['vehicleId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      batteryCapacityKWh:
          (map['batteryCapacityKWh'] as num?)?.toDouble() ?? 0.0,
      currentBatteryPercentage:
          (map['currentBatteryPercentage'] as num?)?.toDouble() ?? 0.0,
      connectorType: map['connectorType'] as String? ?? '',
      efficiencyWhPerKm:
          (map['efficiencyWhPerKm'] as num?)?.toDouble() ?? 150.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'brand': brand,
      'model': model,
      'batteryCapacityKWh': batteryCapacityKWh,
      'currentBatteryPercentage': currentBatteryPercentage,
      'connectorType': connectorType,
      'efficiencyWhPerKm': efficiencyWhPerKm,
    };
  }

  @override
  String toString() =>
      'VehicleModel($brand $model, ${batteryCapacityKWh}kWh, '
      '${currentBatteryPercentage.toStringAsFixed(0)}%, $connectorType)';
}
