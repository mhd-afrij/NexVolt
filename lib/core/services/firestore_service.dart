import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

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

  static final Map<String, dynamic> _defaultProfile = {
    'name': 'David',
    'email': 'david@nexvolt.app',
    'homeCity': 'New York, USA',
    'homeLatitude': 40.7128,
    'homeLongitude': -74.0060,
  };

  static const List<VehicleModel> _defaultVehicles = [
    VehicleModel(model: 'Tesla Model X', plate: 'AAA 1111', batteryPercent: 77),
  ];

  static const List<StationModel> _defaultStations = [
    StationModel(
      id: 'station_1',
      name: 'Tesla Station',
      address: 'Hanover St 24',
      distanceKm: 1.2,
      latitude: 40.7145,
      longitude: -74.0051,
    ),
  ];

  static final List<ChargingSessionModel> _defaultActivity = [
    ChargingSessionModel(
      stationName: 'Tesla Station',
      energyKwh: 12.4,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  Map<String, dynamic> _profile = {..._defaultProfile};
  List<VehicleModel> _vehicles = [];
  List<StationModel> _stations = [];
  List<ChargingSessionModel> _activity = [];

  final _profileController = StreamController<Map<String, dynamic>>.broadcast();
  final _vehiclesController = StreamController<List<VehicleModel>>.broadcast();
  final _stationsController = StreamController<List<StationModel>>.broadcast();
  final _activityController =
      StreamController<List<ChargingSessionModel>>.broadcast();

  bool get _useRemoteDb => _firestore != null;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore!.collection('profiles');
  CollectionReference<Map<String, dynamic>> get _vehiclesCollection =>
      _firestore!.collection('vehicles');
  CollectionReference<Map<String, dynamic>> get _stationsCollection =>
      _firestore!.collection('stations');
  CollectionReference<Map<String, dynamic>> get _chargingActivity =>
      _firestore!.collection('charging_activity');

  Future<void> seedDefaults() async {
    _vehicles = [..._defaultVehicles];
    _stations = [..._defaultStations];
    _activity = [..._defaultActivity];

    if (_useRemoteDb) {
      await _seedFirestoreDefaults();
    }

    _profileController.add(_profile);
    _vehiclesController.add(_vehicles);
    _stationsController.add(_stations);
    _activityController.add(_activity);
  }

  Stream<Map<String, dynamic>> watchProfile() async* {
    if (_useRemoteDb) {
      yield* _profiles
          .doc('default')
          .snapshots()
          .map((doc) => doc.data() ?? {..._defaultProfile});
      return;
    }
    yield _profile;
    yield* _profileController.stream;
  }

  Stream<List<VehicleModel>> watchVehicles() async* {
    if (_useRemoteDb) {
      yield* _vehiclesCollection.snapshots().map(
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
      yield* _stationsCollection.snapshots().map(
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
      yield* _chargingActivity
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
      await _profiles.doc('default').set({
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
      await _profiles.doc('default').set({
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
      await _chargingActivity.add(entry.toMap());
      return;
    }

    _activity = [entry, ..._activity];
    _activityController.add(_activity);
  }

  Future<void> _seedFirestoreDefaults() async {
    await _profiles
        .doc('default')
        .set(_defaultProfile, SetOptions(merge: true));

    for (final vehicle in _defaultVehicles) {
      final docId = vehicle.plate.replaceAll(' ', '_').toLowerCase();
      await _vehiclesCollection
          .doc(docId)
          .set(vehicle.toMap(), SetOptions(merge: true));
    }

    for (final station in _defaultStations) {
      await _stationsCollection
          .doc(station.id)
          .set(station.toMap(), SetOptions(merge: true));
    }

    final activitySnapshot = await _chargingActivity.limit(1).get();
    if (activitySnapshot.docs.isEmpty) {
      for (final session in _defaultActivity) {
        await _chargingActivity.add(session.toMap());
      }
    }
  }
}
