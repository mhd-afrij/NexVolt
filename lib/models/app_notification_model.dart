import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an in-app notification stored in Firestore [notifications] collection.
class AppNotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String type;      // 'session' | 'payment' | 'promo' | 'system'
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  AppNotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    return AppNotificationModel(
      notificationId: map['notificationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'system',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
