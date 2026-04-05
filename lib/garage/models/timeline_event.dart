import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String id;
  final String vehicleId;
  final String title;
  final String type; // inspection, oil, charge, etc.
  final int mileage;
  final DateTime date;
  final double progress; // 0.0 to 1.0

  const TimelineEvent({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.type,
    required this.mileage,
    required this.date,
    required this.progress,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

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

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      mileage: _parseInt(json['mileage']),
      date: _parseDate(json['date']),
      progress: _parseDouble(json['progress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'type': type,
      'mileage': mileage,
      'date': date.toIso8601String(),
      'progress': progress,
    };
  }
}
