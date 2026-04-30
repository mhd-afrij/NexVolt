class BookingModel {
  final String id;
  final String stationId;
  final String stationName;
  final String stationAddress;
  final DateTime date;
  final String timeSlot;
  final int durationMinutes;
  final String chargerType;
  final double pricePerUnit;
  final double tax;
  final double totalAmount;
  final String paymentMethod;
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.date,
    required this.timeSlot,
    required this.durationMinutes,
    required this.chargerType,
    required this.pricePerUnit,
    required this.tax,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  double get subtotal => pricePerUnit * durationMinutes;
  
  double get total => subtotal + tax;

  BookingModel copyWith({
    String? id,
    String? stationId,
    String? stationName,
    String? stationAddress,
    DateTime? date,
    String? timeSlot,
    int? durationMinutes,
    String? chargerType,
    double? pricePerUnit,
    double? tax,
    double? totalAmount,
    String? paymentMethod,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      stationAddress: stationAddress ?? this.stationAddress,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      chargerType: chargerType ?? this.chargerType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class ChargerType {
  final String id;
  final String name;
  final String description;
  final double pricePerUnit;
  final int powerKw;

  const ChargerType({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.powerKw,
  });

  static const List<ChargerType> available = [
    ChargerType(
      id: 'type1',
      name: 'Slow Charge',
      description: '7.2 kW • AC',
      pricePerUnit: 25.0,
      powerKw: 7,
    ),
    ChargerType(
      id: 'type2',
      name: 'Fast Charge',
      description: '22 kW • AC', 
      pricePerUnit: 45.0,
      powerKw: 22,
    ),
    ChargerType(
      id: 'type3',
      name: 'Super Fast',
      description: '50 kW • DC',
      pricePerUnit: 85.0,
      powerKw: 50,
    ),
  ];
}

class TimeSlot {
  final String id;
  final String label;
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.label,
    required this.isAvailable,
  });

  static List<TimeSlot> generateSlots() {
    return List.generate(24, (index) {
      final hour = index;
      final label = '${hour.toString().padLeft(2, '0')}:00';
      return TimeSlot(
        id: label,
        label: label,
        isAvailable: index >= 6 && index <= 22,
      );
    });
  }
}

class DurationOption {
  final int minutes;
  final String label;
  final double priceMultiplier;

  const DurationOption({
    required this.minutes,
    required this.label,
    required this.priceMultiplier,
  });

  static const List<DurationOption> available = [
    DurationOption(minutes: 15, label: '15 min', priceMultiplier: 0.25),
    DurationOption(minutes: 30, label: '30 min', priceMultiplier: 0.5),
    DurationOption(minutes: 60, label: '1 hr', priceMultiplier: 1.0),
    DurationOption(minutes: 120, label: '2 hr', priceMultiplier: 1.8),
    DurationOption(minutes: 240, label: '4 hr', priceMultiplier: 3.5),
  ];
}