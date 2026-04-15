class UserModel {
  const UserModel({
    required this.name,
    required this.email,
    required this.homeCity,
    required this.homeLatitude,
    required this.homeLongitude,
  });

  final String name;
  final String email;
  final String homeCity;
  final double homeLatitude;
  final double homeLongitude;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? 'Driver',
      email: map['email'] as String? ?? '',
      homeCity: map['homeCity'] as String? ?? 'Unknown',
      homeLatitude: (map['homeLatitude'] as num?)?.toDouble() ?? 6.9271,
      homeLongitude: (map['homeLongitude'] as num?)?.toDouble() ?? 79.8612,
    );
  }
}
