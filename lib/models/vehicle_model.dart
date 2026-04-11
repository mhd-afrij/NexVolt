class Vehicle {
  final String vehicleId;
  final String brand;
  final String model;
  final double batteryCapacityKWh;
  final double currentBatteryPercentage;
  final String connectorType;
  final double efficiencyWhPerKm;

  Vehicle({
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.batteryCapacityKWh,
    required this.currentBatteryPercentage,
    required this.connectorType,
    required this.efficiencyWhPerKm,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vehicleId: map['vehicleId'],
      brand: map['brand'],
      model: map['model'],
      batteryCapacityKWh: map['batteryCapacityKWh'].toDouble(),
      currentBatteryPercentage: map['currentBatteryPercentage'].toDouble(),
      connectorType: map['connectorType'],
      efficiencyWhPerKm: map['efficiencyWhPerKm'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'brand': brand,
      'model': model,
      'batteryCapacityKWh': batteryCapacityKWh,
      'currentBatteryPercentage': currentBatteryPercentage,
      'connectorType': connectorType,
      'efficiencyWhPerKm': efficiencyWhPerKm,
    };
  }
}