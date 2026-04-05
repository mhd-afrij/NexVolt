class TimelineEvent {
  final String id;
  final String vehicleId;
  final String title;
  final String type; // inspection, oil, charge, etc.
  final int mileage;
  final DateTime date;
  final double progress; // 0.0 to 1.0

  const TimelineEvent({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.type,
    required this.mileage,
    required this.date,
    required this.progress,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      mileage: json['mileage'] as int,
      date: DateTime.parse(json['date'] as String),
      progress: (json['progress'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'type': type,
      'mileage': mileage,
      'date': date.toIso8601String(),
      'progress': progress,
    };
  }
}
