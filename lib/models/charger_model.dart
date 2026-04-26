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
