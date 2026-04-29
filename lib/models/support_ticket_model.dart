import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user-submitted support ticket in Firestore [support_tickets] collection.
class SupportTicketModel {
  final String ticketId;
  final String userId;
  final String subject;
  final String message;
  final String status;    // 'open' | 'in_review' | 'resolved' | 'closed'
  final DateTime createdAt;

  const SupportTicketModel({
    required this.ticketId,
    required this.userId,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  SupportTicketModel copyWith({
    String? ticketId,
    String? userId,
    String? subject,
    String? message,
    String? status,
    DateTime? createdAt,
  }) {
    return SupportTicketModel(
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SupportTicketModel.fromMap(Map<String, dynamic> map) {
    return SupportTicketModel(
      ticketId: map['ticketId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
