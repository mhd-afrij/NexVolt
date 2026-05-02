import 'package:cloud_firestore/cloud_firestore.dart';

class StationModel {
  final String stationId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final List<String> chargerTypes; // e.g. ['CCS', 'CHAdeMO', 'Type2']
  final double pricePerKWh;
  final bool isActive;
  final String imageUrl;

  const StationModel({
    required this.stationId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availableSlots,
    required this.chargerTypes,
    required this.pricePerKWh,
    required this.isActive,
    required this.imageUrl,
  });

  StationModel copyWith({
    String? stationId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? availableSlots,
    List<String>? chargerTypes,
    double? pricePerKWh,
    bool? isActive,
    String? imageUrl,
  }) {
    return StationModel(
      stationId: stationId ?? this.stationId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availableSlots: availableSlots ?? this.availableSlots,
      chargerTypes: chargerTypes ?? this.chargerTypes,
      pricePerKWh: pricePerKWh ?? this.pricePerKWh,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory StationModel.fromMap(Map<String, dynamic> map) {
    return StationModel(
      stationId: map['stationId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      availableSlots: (map['availableSlots'] as num).toInt(),
      chargerTypes: List<String>.from(map['chargerTypes'] as List),
      pricePerKWh: (map['pricePerKWh'] as num).toDouble(),
      isActive: map['isActive'] as bool? ?? true,
      imageUrl: map['imageUrl'] as String? ?? '',
import '../core/config/app_config.dart';

class StationModel {
  const StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
    this.availableSlots,
    this.totalSlots,
    this.status,
  });

  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final int? availableSlots;
  final int? totalSlots;
  final String? status;

  bool get hasAvailability => availableSlots != null || totalSlots != null;

  bool get isAvailable => (availableSlots ?? 0) > 0;

  String get availabilityLabel {
    if (availableSlots == null && totalSlots == null) {
      return 'Availability live from Firebase';
    }

    if (totalSlots != null && totalSlots! > 0) {
      return '${availableSlots ?? 0} / $totalSlots slots';
    }

    return availableSlots == null
        ? 'Availability live from Firebase'
        : '${availableSlots!} slots available';
  }

  StationModel copyWith({
    String? id,
    String? name,
    String? address,
    double? distanceKm,
    double? latitude,
    double? longitude,
    int? availableSlots,
    int? totalSlots,
    String? status,
  }) {
    return StationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availableSlots: availableSlots ?? this.availableSlots,
      totalSlots: totalSlots ?? this.totalSlots,
      status: status ?? this.status,
    );
  }

  factory StationModel.fromMap(String id, Map<String, dynamic> map) {
    return StationModel(
      id: id,
      name: map['name'] as String? ?? 'Station',
      address: map['address'] as String? ?? 'Address not set',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      latitude:
          (map['latitude'] as num?)?.toDouble() ?? AppConfig.fallbackLatitude,
      longitude:
          (map['longitude'] as num?)?.toDouble() ?? AppConfig.fallbackLongitude,
      availableSlots: (map['availableSlots'] as num?)?.toInt(),
      totalSlots: (map['totalSlots'] as num?)?.toInt(),
      status: map['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'availableSlots': availableSlots,
      'chargerTypes': chargerTypes,
      'pricePerKWh': pricePerKWh,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }
}

/// Fallback mock stations for demo/testing when Firestore is empty.
List<StationModel> mockStations() {
  return [
    StationModel(
      stationId: 'station_001',
      name: 'Colombo EV Hub',
      address: 'Galle Road, Colombo 03',
      latitude: 6.8961,
      longitude: 79.8528,
      availableSlots: 6,
      chargerTypes: ['CCS', 'CHAdeMO', 'Type2'],
      pricePerKWh: 45.0,
      isActive: true,
      imageUrl: '',
    ),
    StationModel(
      stationId: 'station_002',
      name: 'Kandy Charge Point',
      address: 'Katugastota Road, Kandy',
      latitude: 7.2906,
      longitude: 80.6337,
      availableSlots: 4,
      chargerTypes: ['CCS', 'Type2'],
      pricePerKWh: 42.0,
      isActive: true,
      imageUrl: '',
    ),
  ];
}
      'name': name,
      'address': address,
      'distanceKm': distanceKm,
      'latitude': latitude,
      'longitude': longitude,
      if (availableSlots != null) 'availableSlots': availableSlots,
      if (totalSlots != null) 'totalSlots': totalSlots,
      if (status != null) 'status': status,
    };
  }
}
