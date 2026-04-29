import 'package:cloud_firestore/cloud_firestore.dart';

class ChargingSessionModel {
  final String sessionId;
  final String bookingId;
  final String userId;
  final String stationId;
  final String stationName;
  final DateTime startTime;
  final DateTime? endTime;
  final int currentPercentage;
  final double energyDeliveredKWh;
  final int durationMinutes;
  final String status; // waiting | charging | completed | stopped

  const ChargingSessionModel({
    required this.sessionId,
    required this.bookingId,
    required this.userId,
    required this.stationId,
    required this.stationName,
    required this.startTime,
    this.endTime,
    required this.currentPercentage,
    required this.energyDeliveredKWh,
    required this.durationMinutes,
    required this.status,
  });

  ChargingSessionModel copyWith({
    String? sessionId,
    String? bookingId,
    String? userId,
    String? stationId,
    String? stationName,
    DateTime? startTime,
    DateTime? endTime,
    int? currentPercentage,
    double? energyDeliveredKWh,
    int? durationMinutes,
    String? status,
  }) {
    return ChargingSessionModel(
      sessionId: sessionId ?? this.sessionId,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentPercentage: currentPercentage ?? this.currentPercentage,
      energyDeliveredKWh: energyDeliveredKWh ?? this.energyDeliveredKWh,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
    );
  }

  factory ChargingSessionModel.fromMap(Map<String, dynamic> map) {
    DateTime _ts(dynamic v) =>
        v is Timestamp ? v.toDate() : DateTime.parse(v.toString());
    DateTime? _tsOrNull(dynamic v) =>
        v == null ? null : (v is Timestamp ? v.toDate() : DateTime.parse(v.toString()));

    return ChargingSessionModel(
      sessionId: map['sessionId'] as String,
      bookingId: map['bookingId'] as String,
      userId: map['userId'] as String,
      stationId: map['stationId'] as String,
      stationName: map['stationName'] as String,
      startTime: _ts(map['startTime']),
      endTime: _tsOrNull(map['endTime']),
      currentPercentage: (map['currentPercentage'] as num).toInt(),
      energyDeliveredKWh: (map['energyDeliveredKWh'] as num).toDouble(),
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'bookingId': bookingId,
      'userId': userId,
      'stationId': stationId,
      'stationName': stationName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'currentPercentage': currentPercentage,
      'energyDeliveredKWh': energyDeliveredKWh,
      'durationMinutes': durationMinutes,
      'status': status,
    };
  }
}

class ChargingSessionStatus {
  static const String waiting = 'waiting';
  static const String charging = 'charging';
  static const String completed = 'completed';
  static const String stopped = 'stopped';
}
