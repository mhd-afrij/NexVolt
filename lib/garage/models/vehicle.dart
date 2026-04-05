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

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      name: json['name'] as String,
      plateNumber: json['plateNumber'] as String,
      battery: (json['battery'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
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
