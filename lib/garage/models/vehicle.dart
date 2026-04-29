class Vehicle {
  final String id;
  final String name;
  final String plateNumber;
  final double battery; // 0.0 to 100.0
  final String imageUrl;
  final String location;

  const Vehicle({
    required this.id,
    required this.name,
    required this.plateNumber,
    required this.battery,
    required this.imageUrl,
    required this.location,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? '',
      battery: _parseDouble(json['battery']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plateNumber': plateNumber,
      'battery': battery,
      'imageUrl': imageUrl,
      'location': location,
    };
  }
}
