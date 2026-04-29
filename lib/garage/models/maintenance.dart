import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String title;
  final String status; // Completed, Upcoming
  final DateTime date;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.status,
    required this.date,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      date: _parseDate(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'status': status,
      'date': date.toIso8601String(),
    };
  }
}
