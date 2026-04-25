import 'package:cloud_firestore/cloud_firestore.dart';

/// Minimal charging station model used within the Trip Planner feature.
class StationModel {
  final String stationId;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> chargerTypes; // e.g. ["Type2", "CCS"]
  final int availableSlots;
  final bool isActive;

  const StationModel({
    required this.stationId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.chargerTypes,
    required this.availableSlots,
    required this.isActive,
  });

  StationModel copyWith({
    String? stationId,
    String? name,
    double? latitude,
    double? longitude,
    List<String>? chargerTypes,
    int? availableSlots,
    bool? isActive,
  }) {
    return StationModel(
      stationId: stationId ?? this.stationId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      chargerTypes: chargerTypes ?? this.chargerTypes,
      availableSlots: availableSlots ?? this.availableSlots,
      isActive: isActive ?? this.isActive,
    );
  }

  factory StationModel.fromMap(Map<String, dynamic> map) {
    // chargerTypes may be stored as List<dynamic> in Firestore
    final rawTypes = map['chargerTypes'];
    final List<String> types = rawTypes is List
        ? rawTypes.map((e) => e.toString()).toList()
        : <String>[];

    return StationModel(
      stationId: map['stationId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      chargerTypes: types,
      availableSlots: (map['availableSlots'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'chargerTypes': chargerTypes,
      'availableSlots': availableSlots,
      'isActive': isActive,
    };
  }

  @override
  String toString() =>
      'StationModel($name, slots: $availableSlots, types: $chargerTypes)';
}
