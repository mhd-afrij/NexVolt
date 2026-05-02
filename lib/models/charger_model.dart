import 'package:cloud_firestore/cloud_firestore.dart';

class ChargerModel {
  final String chargerId;
  final String stationId;
  final String chargerType; // CCS | CHAdeMO | Type2
  final String status; // available | occupied | offline

  const ChargerModel({
    required this.chargerId,
    required this.stationId,
    required this.chargerType,
    required this.status,
  });

  ChargerModel copyWith({
    String? chargerId,
    String? stationId,
    String? chargerType,
    String? status,
  }) {
    return ChargerModel(
      chargerId: chargerId ?? this.chargerId,
      stationId: stationId ?? this.stationId,
      chargerType: chargerType ?? this.chargerType,
      status: status ?? this.status,
    );
  }

  factory ChargerModel.fromMap(Map<String, dynamic> map) {
    return ChargerModel(
      chargerId: map['chargerId'] as String,
      stationId: map['stationId'] as String,
      chargerType: map['chargerType'] as String,
      status: map['status'] as String? ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chargerId': chargerId,
      'stationId': stationId,
      'chargerType': chargerType,
      'status': status,
    };
  }

  bool get isAvailable => status == 'available';
}

/// ---------------------------------------------------------------------------
/// BookingSlotModel — UI helper model representing a selectable time slot.
/// ---------------------------------------------------------------------------
class BookingSlotModel {
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final bool isAvailable;

  const BookingSlotModel({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.isAvailable,
  });

  BookingSlotModel copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? isAvailable,
  }) {
    return BookingSlotModel(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
      'isAvailable': isAvailable,
    };
  }
class ChargerModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String chargerType;
  final String address;

  ChargerModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.chargerType,
    required this.address,
  });

  factory ChargerModel.fromMap(Map<String, dynamic> map, String id) {
    return ChargerModel(
      id: id,
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      chargerType: map['chargerType'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
