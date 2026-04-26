import 'package:cloud_firestore/cloud_firestore.dart';

class ChargingSessionModel {
  ChargingSessionModel({
    required this.stationName,
    required this.energyKwh,
    required this.timestamp,
  });

  final String stationName;
  final double energyKwh;
  final DateTime timestamp;

  factory ChargingSessionModel.fromMap(Map<String, dynamic> map) {
    final raw = map['timestamp'];
    DateTime parsed;
    if (raw is DateTime) {
      parsed = raw;
    } else if (raw is Timestamp) {
      parsed = raw.toDate();
    } else if (raw is String) {
      parsed = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsed = DateTime.now();
    }

    return ChargingSessionModel(
      stationName: map['stationName'] as String? ?? 'Unknown station',
      energyKwh: (map['energyKwh'] as num?)?.toDouble() ?? 0,
      timestamp: parsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationName': stationName,
      'energyKwh': energyKwh,
      'timestamp': timestamp,
    };
  }
}
