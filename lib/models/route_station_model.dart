import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a charging station that has been evaluated and scored
/// for recommendation along a specific route.
class RouteStationModel {
  final String stationId;
  final String name;
  final LatLng position;
  final List<String> chargerTypes;
  final int availableSlots;

  /// Straight-line distance from the route midpoint in km.
  final double distanceFromRouteMidpointKm;

  /// Whether this station matches the user's preferred connector type.
  final bool isConnectorMatch;

  const RouteStationModel({
    required this.stationId,
    required this.name,
    required this.position,
    required this.chargerTypes,
    required this.availableSlots,
    required this.distanceFromRouteMidpointKm,
    required this.isConnectorMatch,
  });

  RouteStationModel copyWith({
    String? stationId,
    String? name,
    LatLng? position,
    List<String>? chargerTypes,
    int? availableSlots,
    double? distanceFromRouteMidpointKm,
    bool? isConnectorMatch,
  }) {
    return RouteStationModel(
      stationId: stationId ?? this.stationId,
      name: name ?? this.name,
      position: position ?? this.position,
      chargerTypes: chargerTypes ?? this.chargerTypes,
      availableSlots: availableSlots ?? this.availableSlots,
      distanceFromRouteMidpointKm:
          distanceFromRouteMidpointKm ?? this.distanceFromRouteMidpointKm,
      isConnectorMatch: isConnectorMatch ?? this.isConnectorMatch,
    );
  }

  factory RouteStationModel.fromMap(Map<String, dynamic> map) {
    final rawTypes = map['chargerTypes'];
    final List<String> types = rawTypes is List
        ? rawTypes.map((e) => e.toString()).toList()
        : <String>[];

    return RouteStationModel(
      stationId: map['stationId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      position: LatLng(
        (map['latitude'] as num?)?.toDouble() ?? 0.0,
        (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      chargerTypes: types,
      availableSlots: (map['availableSlots'] as num?)?.toInt() ?? 0,
      distanceFromRouteMidpointKm:
          (map['distanceFromRouteMidpointKm'] as num?)?.toDouble() ?? 0.0,
      isConnectorMatch: map['isConnectorMatch'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'name': name,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'chargerTypes': chargerTypes,
      'availableSlots': availableSlots,
      'distanceFromRouteMidpointKm': distanceFromRouteMidpointKm,
      'isConnectorMatch': isConnectorMatch,
    };
  }

  @override
  String toString() =>
      'RouteStationModel($name, ${distanceFromRouteMidpointKm.toStringAsFixed(1)} km from midpoint)';
}
