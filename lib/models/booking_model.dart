import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a full EV charging slot booking.
class BookingModel {
  final String bookingId;
  final String userId;
  final String stationId;
  final String stationName;
  final String stationAddress;
  final String vehicleId;
  final String vehicleName;
  final String chargerType;
  final String chargerId;
  final DateTime bookingDate;
  final DateTime slotStartTime;
  final DateTime slotEndTime;
  final int durationMinutes;
  final double amount;
  final double tax;
  final double totalAmount;
  final String paymentStatus; // pending | paid | failed | refunded
  final String bookingStatus; // draft | payment_pending | upcoming | started | completed | cancelled | expired
  final String qrCodeValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  const BookingModel({
    required this.bookingId,
    required this.userId,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.vehicleId,
    required this.vehicleName,
    required this.chargerType,
    required this.chargerId,
    required this.bookingDate,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.durationMinutes,
    required this.amount,
    required this.tax,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.qrCodeValue,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.completedAt,
  });

  BookingModel copyWith({
    String? bookingId,
    String? userId,
    String? stationId,
    String? stationName,
    String? stationAddress,
    String? vehicleId,
    String? vehicleName,
    String? chargerType,
    String? chargerId,
    DateTime? bookingDate,
    DateTime? slotStartTime,
    DateTime? slotEndTime,
    int? durationMinutes,
    double? amount,
    double? tax,
    double? totalAmount,
    String? paymentStatus,
    String? bookingStatus,
    String? qrCodeValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    DateTime? completedAt,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      stationAddress: stationAddress ?? this.stationAddress,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      chargerType: chargerType ?? this.chargerType,
      chargerId: chargerId ?? this.chargerId,
      bookingDate: bookingDate ?? this.bookingDate,
      slotStartTime: slotStartTime ?? this.slotStartTime,
      slotEndTime: slotEndTime ?? this.slotEndTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      amount: amount ?? this.amount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    DateTime _ts(dynamic v) =>
        v is Timestamp ? v.toDate() : DateTime.parse(v.toString());

    return BookingModel(
      bookingId: map['bookingId'] as String,
      userId: map['userId'] as String,
      stationId: map['stationId'] as String,
      stationName: map['stationName'] as String,
      stationAddress: map['stationAddress'] as String,
      vehicleId: map['vehicleId'] as String,
      vehicleName: map['vehicleName'] as String,
      chargerType: map['chargerType'] as String,
      chargerId: map['chargerId'] as String,
      bookingDate: _ts(map['bookingDate']),
      slotStartTime: _ts(map['slotStartTime']),
      slotEndTime: _ts(map['slotEndTime']),
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      amount: (map['amount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      paymentStatus: map['paymentStatus'] as String,
      bookingStatus: map['bookingStatus'] as String,
      qrCodeValue: map['qrCodeValue'] as String? ?? '',
      createdAt: _ts(map['createdAt']),
      updatedAt: _ts(map['updatedAt']),
      cancelledAt: map['cancelledAt'] != null ? _ts(map['cancelledAt']) : null,
      completedAt: map['completedAt'] != null ? _ts(map['completedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'stationId': stationId,
      'stationName': stationName,
      'stationAddress': stationAddress,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'chargerType': chargerType,
      'chargerId': chargerId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'slotStartTime': Timestamp.fromDate(slotStartTime),
      'slotEndTime': Timestamp.fromDate(slotEndTime),
      'durationMinutes': durationMinutes,
      'amount': amount,
      'tax': tax,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'qrCodeValue': qrCodeValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Helper: true if this booking can be cancelled
  bool get isCancellable =>
      bookingStatus == 'upcoming' || bookingStatus == 'payment_pending';

  /// Helper: true if this booking can be rescheduled
  bool get isReschedulable => bookingStatus == 'upcoming';

  /// Helper: true if charging can be started
  bool get canStartCharging => bookingStatus == 'upcoming';
}

/// Booking status constants for safe comparisons
class BookingStatus {
  static const String draft = 'draft';
  static const String paymentPending = 'payment_pending';
  static const String upcoming = 'upcoming';
  static const String started = 'started';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String expired = 'expired';
}

/// Payment status constants
class PaymentStatus {
  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String failed = 'failed';
  static const String refunded = 'refunded';
}
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
