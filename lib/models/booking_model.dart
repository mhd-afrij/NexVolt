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
