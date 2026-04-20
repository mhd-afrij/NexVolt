class VehicleModel {
  const VehicleModel({
    required this.model,
    required this.plate,
    required this.batteryPercent,
  });

  final String model;
  final String plate;
  final int batteryPercent;

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      model: map['model'] as String? ?? 'Unknown Vehicle',
      plate: map['plate'] as String? ?? '-',
      batteryPercent: (map['batteryPercent'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'model': model, 'plate': plate, 'batteryPercent': batteryPercent};
  }
}
