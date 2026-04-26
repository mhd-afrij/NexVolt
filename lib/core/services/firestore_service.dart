import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/charging_session_model.dart';
import '../../models/station_model.dart';
import '../../models/vehicle_model.dart';
import 'firebase_auth_service.dart';

class AppRepository {
  static const String _rootCollection = 'nexvolt-db';
  static const String _docTypeUser = 'user';
  static const String _docTypeVehicle = 'vehicle';
  static const String _docTypeStation = 'station';
  static const String _docTypeChargingSession = 'charging_session';

  AppRepository({bool useRemoteDb = false})
    : _useRemoteDb = useRemoteDb,
      _firestore = useRemoteDb ? FirebaseFirestore.instance : null;

  final bool _useRemoteDb;
  final FirebaseFirestore? _firestore;

  Map<String, dynamic> _profile = const <String, dynamic>{};
  List<VehicleModel> _vehicles = [];
  List<StationModel> _stations = [];
  List<ChargingSessionModel> _activity = [];

  final _profileController = StreamController<Map<String, dynamic>>.broadcast();
  final _vehiclesController = StreamController<List<VehicleModel>>.broadcast();
  final _stationsController = StreamController<List<StationModel>>.broadcast();
  final _activityController =
      StreamController<List<ChargingSessionModel>>.broadcast();

  static ({String firstName, String lastName}) _splitName(String fullName) {
    final cleaned = fullName.trim();
    if (cleaned.isEmpty) {
      return (firstName: '', lastName: '');
    }

    final parts = cleaned
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return (firstName: '', lastName: '');
    }

    if (parts.length == 1) {
      return (firstName: parts.first, lastName: '');
    }

    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }

  static String _preferredProfileName() {
    final displayName = FirebaseAuthService.currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = FirebaseAuthService.currentUser?.email?.trim();
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    return '';
  }

  Future<void> seedDefaults() async {
    if (_useRemoteDb && _firestore != null) {
      await _createNexvoltDbCollection();
      await _ensureCurrentUserProfileDoc();
      return;
    }

    _profile = const <String, dynamic>{};
    _vehicles = const <VehicleModel>[];
    _stations = const <StationModel>[];
    _activity = const <ChargingSessionModel>[];

    _profileController.add(_profile);
    _vehiclesController.add(_vehicles);
    _stationsController.add(_stations);
    _activityController.add(_activity);
  }

  Future<void> _createNexvoltDbCollection() async {
    await _firestore!.collection(_rootCollection).doc('bootstrap').set(
      <String, dynamic>{
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'app-startup',
      },
      SetOptions(merge: true),
    );
  }

  String? get _currentUserId => FirebaseAuthService.currentUserId;

  CollectionReference<Map<String, dynamic>>? get _dbRootCollection {
    final firestore = _firestore;
    if (firestore == null) {
      return null;
    }

    return firestore.collection(_rootCollection);
  }

  DocumentReference<Map<String, dynamic>>? get _currentUserDoc {
    final userId = _currentUserId;
    final rootCollection = _dbRootCollection;
    if (userId == null || rootCollection == null) {
      return null;
    }
    return rootCollection.doc(userId);
  }

  Future<void> _ensureCurrentUserProfileDoc() async {
    final userDoc = _currentUserDoc;
    if (userDoc == null) {
      return;
    }

    final profileName = _preferredProfileName();
    final parsed = _splitName(profileName);
    final authEmail = FirebaseAuthService.currentUser?.email?.trim() ?? '';

    await userDoc.set(<String, dynamic>{
      'userId': userDoc.id,
      if (profileName.isNotEmpty) 'name': profileName,
      if (parsed.firstName.isNotEmpty) 'firstName': parsed.firstName,
      if (parsed.lastName.isNotEmpty) 'lastName': parsed.lastName,
      if (authEmail.isNotEmpty) 'email': authEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> watchProfile() async* {
    if (_useRemoteDb && _firestore != null) {
      final userDoc = _currentUserDoc;
      if (userDoc == null) {
        yield const <String, dynamic>{};
        return;
      }

      yield* userDoc.snapshots().map((snapshot) {
        if (!snapshot.exists) {
          return const <String, dynamic>{};
        }
        return snapshot.data() ?? const <String, dynamic>{};
      });
      return;
    }

    yield _profile;
    yield* _profileController.stream;
  }

  Stream<List<VehicleModel>> watchVehicles() async* {
    if (_useRemoteDb && _firestore != null) {
      final userId = _currentUserId;
      if (userId == null) {
        yield const <VehicleModel>[];
        return;
      }

      final rootCollection = _dbRootCollection;
      if (rootCollection == null) {
        yield const <VehicleModel>[];
        return;
      }

      yield* rootCollection
          .where('type', isEqualTo: _docTypeVehicle)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final vehicles = snapshot.docs
                .map((doc) => VehicleModel.fromMap(doc.data()))
                .toList(growable: false);
            return vehicles;
          });
      return;
    }

    yield _vehicles;
    yield* _vehiclesController.stream;
  }

  Stream<List<StationModel>> watchFavoriteStations() async* {
    if (_useRemoteDb && _firestore != null) {
      yield* watchStations();
      return;
    }

    yield _stations;
    yield* _stationsController.stream;
  }

  Stream<List<StationModel>> watchStations() async* {
    if (_useRemoteDb && _firestore != null) {
      final rootCollection = _dbRootCollection;
      if (rootCollection == null) {
        yield const <StationModel>[];
        return;
      }

      yield* rootCollection
          .where('type', isEqualTo: _docTypeStation)
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

  Future<bool> isCurrentUserAdmin() async {
    return true;
  }

  Future<void> updateStationAvailability({
    required String stationId,
    required int availableSlots,
    required int totalSlots,
    required String status,
  }) async {
    if (_useRemoteDb && _firestore != null) {
      final rootCollection = _dbRootCollection;
      if (rootCollection != null) {
        await rootCollection.doc(stationId).set(<String, dynamic>{
          'type': _docTypeStation,
          'availableSlots': availableSlots,
          'totalSlots': totalSlots,
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return;
    }

    _stations = _stations
        .map(
          (station) => station.id == stationId
              ? station.copyWith(
                  availableSlots: availableSlots,
                  totalSlots: totalSlots,
                  status: status,
                )
              : station,
        )
        .toList(growable: false);
    _stationsController.add(_stations);
  }

  Stream<List<ChargingSessionModel>> watchChargingActivity() async* {
    if (_useRemoteDb && _firestore != null) {
      final userId = _currentUserId;
      if (userId == null) {
        yield const <ChargingSessionModel>[];
        return;
      }

      final rootCollection = _dbRootCollection;
      if (rootCollection == null) {
        yield const <ChargingSessionModel>[];
        return;
      }

      yield* rootCollection
          .where('type', isEqualTo: _docTypeChargingSession)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final sessions = snapshot.docs
                .map((doc) => ChargingSessionModel.fromMap(doc.data()))
                .toList(growable: false);
            sessions.sort(
              (left, right) => right.timestamp.compareTo(left.timestamp),
            );
            return sessions;
          });
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
    final parsed = _splitName(name);

    if (_useRemoteDb && _firestore != null) {
      final userDoc = _currentUserDoc;
      if (userDoc != null) {
        await userDoc.set(<String, dynamic>{
          'type': _docTypeUser,
          'userId': userDoc.id,
          'name': name,
          'firstName': parsed.firstName,
          'lastName': parsed.lastName,
          'email': email,
          'homeCity': homeCity,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return;
    }

    _profile = {
      ..._profile,
      'name': name,
      'firstName': parsed.firstName,
      'lastName': parsed.lastName,
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
    if (_useRemoteDb && _firestore != null) {
      final userDoc = _currentUserDoc;
      if (userDoc != null) {
        await userDoc.set(<String, dynamic>{
          'type': _docTypeUser,
          'userId': userDoc.id,
          'homeCity': city,
          'homeLatitude': latitude,
          'homeLongitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
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
    if (_useRemoteDb && _firestore != null) {
      final userId = _currentUserId;
      if (userId != null) {
        final rootCollection = _dbRootCollection;
        if (rootCollection != null) {
          await rootCollection.add({
            'type': _docTypeChargingSession,
            'userId': userId,
            'stationName': stationName,
            'energyKwh': energyKwh,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
      return;
    }

    final entry = ChargingSessionModel(
      stationName: stationName,
      energyKwh: energyKwh,
      timestamp: DateTime.now(),
    );

    _activity = [entry, ..._activity];
    _activityController.add(_activity);
  }

  Future<void> addVehicle({
    String? userId,
    required String model,
    required String plate,
    required int batteryPercent,
    String? vehicle,
    String? vehicleType,
    String? company,
    String? battery,
    String? connector,
    String? batteryVoltage,
    String? connectorType,
  }) async {
    if (_useRemoteDb && _firestore != null) {
      final ownerId = userId ?? _currentUserId;
      if (ownerId != null) {
        final rootCollection = _dbRootCollection;
        if (rootCollection != null) {
          await rootCollection.add({
            'type': _docTypeVehicle,
            'userId': ownerId,
            if (vehicle != null) 'vehicle': vehicle,
            'model': model,
            'plate': plate,
            'batteryPercent': batteryPercent,
            if (vehicleType != null) 'vehicleType': vehicleType,
            if (company != null) 'company': company,
            if (batteryVoltage != null) 'batteryVoltage': batteryVoltage,
            if (connectorType != null) 'connectorType': connectorType,
            if (battery != null) 'battery': battery,
            if (connector != null) 'connector': connector,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return;
    }

    final next = VehicleModel(
      model: model,
      plate: plate,
      batteryPercent: batteryPercent,
      batteryVoltage: batteryVoltage ?? battery ?? '',
      connectorType: connectorType ?? connector ?? '',
    );
    _vehicles = [next, ..._vehicles];
    _vehiclesController.add(_vehicles);
  }
}
