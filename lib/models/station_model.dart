class StationModel {
  const StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double latitude;
  final double longitude;

  factory StationModel.fromMap(String id, Map<String, dynamic> map) {
    return StationModel(
      id: id,
      name: map['name'] as String? ?? 'Station',
      address: map['address'] as String? ?? 'Address not set',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 6.9271,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 79.8612,
    );
  }
}
