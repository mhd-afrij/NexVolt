import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's favourite charging station in Firestore [favorites] collection.
class FavoriteStationModel {
  final String favoriteId;
  final String userId;
  final String stationId;
  final String stationName;
  final DateTime createdAt;

  const FavoriteStationModel({
    required this.favoriteId,
    required this.userId,
    required this.stationId,
    required this.stationName,
    required this.createdAt,
  });

  FavoriteStationModel copyWith({
    String? favoriteId,
    String? userId,
    String? stationId,
    String? stationName,
    DateTime? createdAt,
  }) {
    return FavoriteStationModel(
      favoriteId: favoriteId ?? this.favoriteId,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FavoriteStationModel.fromMap(Map<String, dynamic> map) {
    return FavoriteStationModel(
      favoriteId: map['favoriteId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      stationId: map['stationId'] as String? ?? '',
      stationName: map['stationName'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'favoriteId': favoriteId,
      'userId': userId,
      'stationId': stationId,
      'stationName': stationName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
