import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_config.dart';
import 'firebase_auth_service.dart';

class FirestoreSampleImporter {
  FirestoreSampleImporter._();

  static const String _rootCollection = 'nexvolt-db';
  static const String _docTypeUser = 'user';
  static const String _docTypeVehicle = 'vehicle';
  static const String _docTypeStation = 'station';
  static const String _docTypeChargingSession = 'charging_session';

  static Future<void> importSampleData() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final currentUser = FirebaseAuthService.currentUser;
    final userId = currentUser?.uid;

    if (userId == null || userId.trim().isEmpty) {
      throw StateError('Authenticated user required for sample data import.');
    }

    final userName = (currentUser?.displayName ?? '').trim();
    final userEmail = (currentUser?.email ?? '').trim();

    final stationARef = firestore.collection(_rootCollection).doc();
    final stationBRef = firestore.collection(_rootCollection).doc();
    final vehicleRef = firestore.collection(_rootCollection).doc();
    final sessionRef = firestore.collection(_rootCollection).doc();

    final bootstrapRef = firestore.collection(_rootCollection).doc('bootstrap');
    batch.set(bootstrapRef, <String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'source': 'app-startup',
    }, SetOptions(merge: true));

    final userRef = firestore.collection(_rootCollection).doc(userId);
    batch.set(userRef, <String, dynamic>{
      'type': _docTypeUser,
      'userId': userId,
      'name': userName.isEmpty ? 'NexVolt User' : userName,
      'email': userEmail,
      'homeCity': 'Unknown',
      'homeLatitude': AppConfig.fallbackLatitude,
      'homeLongitude': AppConfig.fallbackLongitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(vehicleRef, <String, dynamic>{
      'type': _docTypeVehicle,
      'userId': userId,
      'vehicle': 'Demo EV',
      'vehicleType': 'Car',
      'model': 'Demo EV',
      'plate': 'Car',
      'batteryPercent': 65,
      'batteryVoltage': '300-400V',
      'connectorType': 'Type 2 / CCS',
      'battery': '300-400V',
      'connector': 'Type 2 / CCS',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(stationARef, <String, dynamic>{
      'type': _docTypeStation,
      'name': 'NexVolt Demo Station A',
      'address': 'Demo Address A',
      'distanceKm': 2.0,
      'latitude': AppConfig.fallbackLatitude,
      'longitude': AppConfig.fallbackLongitude,
      'availableSlots': 5,
      'totalSlots': 10,
      'status': 'Available',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(stationBRef, <String, dynamic>{
      'type': _docTypeStation,
      'name': 'NexVolt Demo Station B',
      'address': 'Demo Address B',
      'distanceKm': 4.0,
      'latitude': AppConfig.fallbackLatitude,
      'longitude': AppConfig.fallbackLongitude,
      'availableSlots': 2,
      'totalSlots': 8,
      'status': 'Busy',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(sessionRef, <String, dynamic>{
      'type': _docTypeChargingSession,
      'userId': userId,
      'stationName': 'NexVolt Demo Station A',
      'energyKwh': 12.5,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
