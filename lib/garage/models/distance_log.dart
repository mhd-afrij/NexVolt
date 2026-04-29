import 'package:cloud_firestore/cloud_firestore.dart';

class DistanceLog {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double distance;

  const DistanceLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.distance,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory DistanceLog.fromJson(Map<String, dynamic> json) {
    return DistanceLog(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      date: _parseDate(json['date']),
      distance: _parseDouble(json['distance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'distance': distance,
    };
  }
}
