import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final String userId;
  final double amount;
  final String method; // card | wallet | bank_transfer
  final String status; // pending | paid | failed | refunded
  final String transactionRef;
  final DateTime? paidAt;

  const PaymentModel({
    required this.paymentId,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionRef,
    this.paidAt,
  });

  PaymentModel copyWith({
    String? paymentId,
    String? bookingId,
    String? userId,
    double? amount,
    String? method,
    String? status,
    String? transactionRef,
    DateTime? paidAt,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionRef: transactionRef ?? this.transactionRef,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    DateTime? _tsOrNull(dynamic v) =>
        v == null ? null : (v is Timestamp ? v.toDate() : DateTime.parse(v.toString()));

    return PaymentModel(
      paymentId: map['paymentId'] as String,
      bookingId: map['bookingId'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      method: map['method'] as String,
      status: map['status'] as String,
      transactionRef: map['transactionRef'] as String,
      paidAt: _tsOrNull(map['paidAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'transactionRef': transactionRef,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }
}
