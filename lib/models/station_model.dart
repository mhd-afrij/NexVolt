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
