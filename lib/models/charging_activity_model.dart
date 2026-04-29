import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single EV charging session stored in Firestore [charging_sessions] collection.
class ChargingActivityModel {
  final String sessionId;
  final String userId;
  final String stationId;
  final String stationName;
  final double energyDeliveredKWh;
  final double amountPaid;       // in LKR
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String status;           // 'completed' | 'cancelled' | 'in_progress'

  const ChargingActivityModel({
    required this.sessionId,
    required this.userId,
    required this.stationId,
    required this.stationName,
    required this.energyDeliveredKWh,
    required this.amountPaid,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
  });

  ChargingActivityModel copyWith({
    String? sessionId,
    String? userId,
    String? stationId,
    String? stationName,
    double? energyDeliveredKWh,
    double? amountPaid,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? status,
  }) {
    return ChargingActivityModel(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      energyDeliveredKWh: energyDeliveredKWh ?? this.energyDeliveredKWh,
      amountPaid: amountPaid ?? this.amountPaid,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
    );
  }

  factory ChargingActivityModel.fromMap(Map<String, dynamic> map) {
    return ChargingActivityModel(
      sessionId: map['sessionId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      stationId: map['stationId'] as String? ?? '',
      stationName: map['stationName'] as String? ?? '',
      energyDeliveredKWh:
          (map['energyDeliveredKWh'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      status: map['status'] as String? ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'stationId': stationId,
      'stationName': stationName,
      'energyDeliveredKWh': energyDeliveredKWh,
      'amountPaid': amountPaid,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
      'status': status,
    };
  }

  bool get isCompleted => status == 'completed';
}
