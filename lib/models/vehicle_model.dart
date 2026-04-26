class VehicleModel {
  const VehicleModel({
    required this.model,
    required this.plate,
    required this.batteryPercent,
    this.batteryVoltage = '',
    this.connectorType = '',
  });

  final String model;
  final String plate;
  final int batteryPercent;
  final String batteryVoltage;
  final String connectorType;

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    final batteryText = (map['battery'] as String?)?.trim() ?? '';
    final parsedBattery = int.tryParse(
      batteryText.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    final derivedPlate = (map['plate'] as String?)?.trim().isNotEmpty == true
        ? (map['plate'] as String).trim()
        : [
            (map['vehicleType'] as String?)?.trim(),
            (map['company'] as String?)?.trim(),
          ].whereType<String>().where((v) => v.isNotEmpty).join(' ');

    return VehicleModel(
      model: map['model'] as String? ?? 'Unknown Vehicle',
      plate: derivedPlate.isEmpty ? '-' : derivedPlate,
      batteryPercent:
          (map['batteryPercent'] as num?)?.toInt() ?? parsedBattery ?? 0,
      batteryVoltage:
          (map['batteryVoltage'] as String?)?.trim().isNotEmpty == true
          ? (map['batteryVoltage'] as String).trim()
          : (map['battery'] as String?)?.trim() ?? '',
      connectorType:
          (map['connectorType'] as String?)?.trim().isNotEmpty == true
          ? (map['connectorType'] as String).trim()
          : (map['connector'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'plate': plate,
      'batteryPercent': batteryPercent,
      'batteryVoltage': batteryVoltage,
      'connectorType': connectorType,
    };
  }
}
