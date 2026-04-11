class Station {
  final String stationId;
  final String name;
  final double latitude;
  final double longitude;
  final List<dynamic> chargerTypes;
  final int availableSlots;
  final bool isActive;

  Station({
    required this.stationId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.chargerTypes,
    required this.availableSlots,
    required this.isActive,
  });

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      stationId: map['stationId'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      chargerTypes: map['chargerTypes'],
      availableSlots: map['availableSlots'],
      isActive: map['isActive'],
    );
  }

  Map<String, dynamic> toMap() => {
        'stationId': stationId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'chargerTypes': chargerTypes,
        'availableSlots': availableSlots,
        'isActive': isActive,
      };
}