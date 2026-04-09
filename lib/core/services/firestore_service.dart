import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firebase_constants.dart';
import '../../models/charging_session_model.dart';
import '../../models/station_model.dart';
import '../../models/vehicle_model.dart';

class AppRepository {
  AppRepository({required this.firebaseReady}) {
    if (firebaseReady) {
      _db = FirebaseFirestore.instance;
    } else {
      _profile = {
        'name': 'David',
        'email': 'david@nexvolt.app',
        'homeCity': 'New York, USA',
        'homeLatitude': 40.7128,
        'homeLongitude': -74.0060,
      };
      _vehicles = [
        const VehicleModel(
          model: 'Tesla Model X',
          plate: 'AAA 1111',
          batteryPercent: 77,
        ),
      ];
      _stations = [
        const StationModel(
          id: 'station_1',
          name: 'Tesla Station',
          address: 'Hanover St 24',
          distanceKm: 1.2,
          latitude: 40.7145,
          longitude: -74.0051,
        ),
      ];
      _activity = [
        ChargingSessionModel(
          stationName: 'Tesla Station',
          energyKwh: 12.4,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];
    }
  }

  final bool firebaseReady;
  FirebaseFirestore? _db;

  Map<String, dynamic> _profile = {};
  List<VehicleModel> _vehicles = [];
  List<StationModel> _stations = [];
  List<ChargingSessionModel> _activity = [];

  final _profileController = StreamController<Map<String, dynamic>>.broadcast();
  final _vehiclesController = StreamController<List<VehicleModel>>.broadcast();
  final _stationsController = StreamController<List<StationModel>>.broadcast();
  final _activityController =
      StreamController<List<ChargingSessionModel>>.broadcast();

  Future<void> seedDefaults() async {
    if (!firebaseReady) {
      _profileController.add(_profile);
      _vehiclesController.add(_vehicles);
      _stationsController.add(_stations);
      _activityController.add(_activity);
      return;
    }

    final userRef = _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId);

    await userRef.set({
      'name': 'David',
      'email': 'david@nexvolt.app',
      'homeCity': 'New York, USA',
      'homeLatitude': 40.7128,
      'homeLongitude': -74.0060,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await userRef.collection(FirebaseConstants.vehicles).doc('vehicle_1').set({
      'model': 'Tesla Model X',
      'plate': 'AAA 1111',
      'batteryPercent': 77,
    }, SetOptions(merge: true));

    await userRef
        .collection(FirebaseConstants.favoriteStations)
        .doc('station_1')
        .set({
          'name': 'Tesla Station',
          'address': 'Hanover St 24',
          'distanceKm': 1.2,
          'latitude': 40.7145,
          'longitude': -74.0051,
        }, SetOptions(merge: true));

    await userRef
        .collection(FirebaseConstants.chargingActivity)
        .doc('activity_1')
        .set({
          'stationName': 'Tesla Station',
          'energyKwh': 12.4,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> watchProfile() async* {
    if (!firebaseReady) {
      yield _profile;
      yield* _profileController.stream;
      return;
    }

    yield* _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .snapshots()
        .map((doc) => doc.data() ?? <String, dynamic>{});
  }

  Stream<List<VehicleModel>> watchVehicles() async* {
    if (!firebaseReady) {
      yield _vehicles;
      yield* _vehiclesController.stream;
      return;
    }

    yield* _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .collection(FirebaseConstants.vehicles)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => VehicleModel.fromMap(d.data())).toList(),
        );
  }

  Stream<List<StationModel>> watchFavoriteStations() async* {
    if (!firebaseReady) {
      yield _stations;
      yield* _stationsController.stream;
      return;
    }

    yield* _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .collection(FirebaseConstants.favoriteStations)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => StationModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<ChargingSessionModel>> watchChargingActivity() async* {
    if (!firebaseReady) {
      yield _activity;
      yield* _activityController.stream;
      return;
    }

    yield* _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .collection(FirebaseConstants.chargingActivity)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => ChargingSessionModel.fromMap(d.data()))
              .toList(),
        );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String homeCity,
  }) async {
    if (!firebaseReady) {
      _profile = {
        ..._profile,
        'name': name,
        'email': email,
        'homeCity': homeCity,
      };
      _profileController.add(_profile);
      return;
    }

    await _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .set({
          'name': name,
          'email': email,
          'homeCity': homeCity,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> updateHomeLocation({
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    if (!firebaseReady) {
      _profile = {
        ..._profile,
        'homeCity': city,
        'homeLatitude': latitude,
        'homeLongitude': longitude,
      };
      _profileController.add(_profile);
      return;
    }

    await _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .set({
          'homeCity': city,
          'homeLatitude': latitude,
          'homeLongitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> addChargingActivity({
    required String stationName,
    required double energyKwh,
  }) async {
    final entry = ChargingSessionModel(
      stationName: stationName,
      energyKwh: energyKwh,
      timestamp: DateTime.now(),
    );

    if (!firebaseReady) {
      _activity = [entry, ..._activity];
      _activityController.add(_activity);
      return;
    }

    await _db!
        .collection(FirebaseConstants.users)
        .doc(FirebaseConstants.userId)
        .collection(FirebaseConstants.chargingActivity)
        .add({
          'stationName': stationName,
          'energyKwh': energyKwh,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
