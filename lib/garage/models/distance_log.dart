class DistanceLog {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double distance;

  const DistanceLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.distance,
  });

  factory DistanceLog.fromJson(Map<String, dynamic> json) {
    return DistanceLog(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.parse(json['date'] as String),
      distance: (json['distance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'distance': distance,
    };
  }
}
