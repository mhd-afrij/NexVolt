class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String title;
  final String status; // Completed, Upcoming
  final DateTime date;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.status,
    required this.date,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'status': status,
      'date': date.toIso8601String(),
    };
  }
}
