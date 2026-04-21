import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/charging_session_model.dart';
import '../../models/station_model.dart';
import '../../models/vehicle_model.dart';

class AppRepository {
  AppRepository({bool useRemoteDb = true}) {
    if (useRemoteDb) {
      _firestore = FirebaseFirestore.instance;
    }
  }

  FirebaseFirestore? _firestore;

  Map<String, dynamic> _profile = const <String, dynamic>{};
  List<VehicleModel> _vehicles = [];
  List<StationModel> _stations = [];
  List<ChargingSessionModel> _activity = [];

  final _profileController = StreamController<Map<String, dynamic>>.broadcast();
  final _vehiclesController = StreamController<List<VehicleModel>>.broadcast();
  final _stationsController = StreamController<List<StationModel>>.broadcast();
  final _activityController =
      StreamController<List<ChargingSessionModel>>.broadcast();

  bool get _useRemoteDb => _firestore != null;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> seedDefaults() async {
    _profile = const <String, dynamic>{};
    _vehicles = const <VehicleModel>[];
    _stations = const <StationModel>[];
    _activity = const <ChargingSessionModel>[];

    _profileController.add(_profile);
    _vehiclesController.add(_vehicles);
    _stationsController.add(_stations);
    _activityController.add(_activity);
  }

  Stream<Map<String, dynamic>> watchProfile() async* {
    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) {
        yield const <String, dynamic>{};
        return;
      }
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) => doc.data() ?? const <String, dynamic>{});
      return;
    }
    yield _profile;
    yield* _profileController.stream;
  }

  Stream<List<VehicleModel>> watchVehicles() async* {
    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) {
        yield const <VehicleModel>[];
        return;
      }
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => VehicleModel.fromMap(doc.data()))
                .toList(growable: false),
          );
      return;
    }
    yield _vehicles;
    yield* _vehiclesController.stream;
  }

  Stream<List<StationModel>> watchFavoriteStations() async* {
    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) {
        yield const <StationModel>[];
        return;
      }
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => StationModel.fromMap(doc.id, doc.data()))
                .toList(growable: false),
          );
      return;
    }
    yield _stations;
    yield* _stationsController.stream;
  }

  Stream<List<StationModel>> watchStations() async* {
    if (_useRemoteDb) {
      yield* _firestore!
          .collection('stations')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => StationModel.fromMap(doc.id, doc.data()))
                .toList(growable: false),
          );
      return;
    }
    yield _stations;
    yield* _stationsController.stream;
  }

  Stream<List<ChargingSessionModel>> watchChargingActivity() async* {
    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) {
        yield const <ChargingSessionModel>[];
        return;
      }
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('charging_activity')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  final rawTimestamp = data['timestamp'];
                  final timestamp = rawTimestamp is Timestamp
                      ? rawTimestamp.toDate()
                      : rawTimestamp;

                  return ChargingSessionModel.fromMap({
                    ...data,
                    'timestamp': timestamp,
                  });
                })
                .toList(growable: false),
          );
      return;
    }
    yield _activity;
    yield* _activityController.stream;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String homeCity,
  }) async {
    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) return;
      await _firestore!.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'homeCity': homeCity,
      }, SetOptions(merge: true));
      return;
    }

    _profile = {
      ..._profile,
      'name': name,
      'email': email,
      'homeCity': homeCity,
    };
    _profileController.add(_profile);
  }

  Future<void> updateHomeLocation({
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) return;
      await _firestore!.collection('users').doc(uid).set({
        'homeCity': city,
        'homeLatitude': latitude,
        'homeLongitude': longitude,
      }, SetOptions(merge: true));
      return;
    }

    _profile = {
      ..._profile,
      'homeCity': city,
      'homeLatitude': latitude,
      'homeLongitude': longitude,
    };
    _profileController.add(_profile);
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

    if (_useRemoteDb) {
      final uid = _uid;
      if (uid == null) return;
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('charging_activity')
          .add(entry.toMap());
      return;
    }

    _activity = [entry, ..._activity];
    _activityController.add(_activity);
  }
}
