import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a Nexvolt user profile stored in Firestore [users] collection.
class UserProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String language;          // e.g. 'en', 'si', 'ta'
  final String themeMode;         // 'system' | 'light' | 'dark'
  final String membershipType;    // e.g. 'standard', 'premium'
  final bool notificationsEnabled;
  final bool autoReloadEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.language,
    required this.themeMode,
    required this.membershipType,
    required this.notificationsEnabled,
    required this.autoReloadEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with optional overridden fields.
  UserProfileModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? language,
    String? themeMode,
    String? membershipType,
    bool? notificationsEnabled,
    bool? autoReloadEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      membershipType: membershipType ?? this.membershipType,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoReloadEnabled: autoReloadEnabled ?? this.autoReloadEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Deserialises from a Firestore document map.
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      themeMode: map['themeMode'] as String? ?? 'system',
      membershipType: map['membershipType'] as String? ?? 'standard',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      autoReloadEnabled: map['autoReloadEnabled'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Serialises to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'language': language,
      'themeMode': themeMode,
      'membershipType': membershipType,
      'notificationsEnabled': notificationsEnabled,
      'autoReloadEnabled': autoReloadEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Returns a blank/anonymous placeholder profile.
  factory UserProfileModel.empty() {
    final now = DateTime.now();
    return UserProfileModel(
      uid: '',
      fullName: '',
      email: '',
      phone: '',
      profileImageUrl: '',
      language: 'en',
      themeMode: 'system',
      membershipType: 'standard',
      notificationsEnabled: true,
      autoReloadEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}
