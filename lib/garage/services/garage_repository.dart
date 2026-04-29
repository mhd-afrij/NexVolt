import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../models/timeline_event.dart';
import '../models/distance_log.dart';
import '../models/maintenance.dart';

class GarageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const Duration _firestoreTimeout = Duration(seconds: 20);

  Future<List<Vehicle>> getVehicles() async {
    try {
      final snapshot = await _db
          .collection('vehicles')
          .get()
          .timeout(
            _firestoreTimeout,
            onTimeout: () =>
                throw StateError('Firestore getVehicles timed out'),
          );
      return snapshot.docs.map((doc) {
        final json = doc.data();
        json['id'] = doc.id;
        return Vehicle.fromJson(json);
      }).toList();
    } catch (e, st) {
      debugPrint('Firestore getVehicles failed: $e');
      debugPrint(st.toString());
      return _loadSeedVehicles();
    }
  }

  Future<List<TimelineEvent>> getTimelineEvents(String vehicleId) async {
    try {
      final snapshot = await _db
          .collection('timelineEvents')
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      return snapshot.docs.map((doc) {
        final json = doc.data();
        json['id'] = doc.id;
        return TimelineEvent.fromJson(json);
      }).toList();
    } catch (e, st) {
      debugPrint('Firestore getTimelineEvents failed: $e');
      debugPrint(st.toString());
      return _loadSeedTimelineEvents(vehicleId);
    }
  }

  Future<List<DistanceLog>> getDistanceLogs(String vehicleId) async {
    try {
      final snapshot = await _db
          .collection('distanceLogs')
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('date')
          .get();

      return snapshot.docs.map((doc) {
        final json = doc.data();
        json['id'] = doc.id;
        return DistanceLog.fromJson(json);
      }).toList();
    } catch (e, st) {
      debugPrint('Firestore getDistanceLogs failed: $e');
      debugPrint(st.toString());
      return _loadSeedDistanceLogs(vehicleId);
    }
  }

  Future<List<MaintenanceRecord>> getMaintenanceRecords(
    String vehicleId,
  ) async {
    try {
      final snapshot = await _db
          .collection('maintenance')
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      return snapshot.docs.map((doc) {
        final json = doc.data();
        json['id'] = doc.id;
        return MaintenanceRecord.fromJson(json);
      }).toList();
    } catch (e, st) {
      debugPrint('Firestore getMaintenanceRecords failed: $e');
      debugPrint(st.toString());
      return _loadSeedMaintenanceRecords(vehicleId);
    }
  }

  Future<Vehicle> addVehicle({
    required String name,
    required String plateNumber,
    required double battery,
    required String imageUrl,
    required String location,
  }) async {
    final docRef = await _db.collection('vehicles').add({
      'name': name,
      'plateNumber': plateNumber,
      'battery': battery,
      'imageUrl': imageUrl,
      'location': location,
    });

    final newDoc = await docRef.get();
    final json = newDoc.data()!;
    json['id'] = newDoc.id;
    return Vehicle.fromJson(json);
  }

  Future<TimelineEvent> addTimelineEvent({
    required String vehicleId,
    required String title,
    required String type,
    required int mileage,
    required DateTime date,
    required double progress,
  }) async {
    final docRef = await _db.collection('timelineEvents').add({
      'vehicleId': vehicleId,
      'title': title,
      'type': type,
      'mileage': mileage,
      'date': date.toIso8601String(),
      'progress': progress,
    });

    final newDoc = await docRef.get();
    final json = newDoc.data()!;
    json['id'] = newDoc.id;
    return TimelineEvent.fromJson(json);
  }

  Future<DistanceLog> addDistanceLog({
    required String vehicleId,
    required DateTime date,
    required double distance,
  }) async {
    final docRef = await _db.collection('distanceLogs').add({
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'distance': distance,
    });

    final newDoc = await docRef.get();
    final json = newDoc.data()!;
    json['id'] = newDoc.id;
    return DistanceLog.fromJson(json);
  }

  Future<MaintenanceRecord> addMaintenanceRecord({
    required String vehicleId,
    required String title,
    required String status,
    required DateTime date,
  }) async {
    final docRef = await _db.collection('maintenance').add({
      'vehicleId': vehicleId,
      'title': title,
      'status': status,
      'date': date.toIso8601String(),
    });

    final newDoc = await docRef.get();
    final json = newDoc.data()!;
    json['id'] = newDoc.id;
    return MaintenanceRecord.fromJson(json);
  }

  Future<Vehicle> updateVehicle({
    required String id,
    String? name,
    String? plateNumber,
    double? battery,
    String? imageUrl,
    String? location,
  }) async {
    final updateData = <String, Object?>{};
    if (name != null) updateData['name'] = name;
    if (plateNumber != null) updateData['plateNumber'] = plateNumber;
    if (battery != null) updateData['battery'] = battery;
    if (imageUrl != null) updateData['imageUrl'] = imageUrl;
    if (location != null) updateData['location'] = location;

    await _db.collection('vehicles').doc(id).update(updateData);
    final updatedDoc = await _db.collection('vehicles').doc(id).get();
    final json = updatedDoc.data()!;
    json['id'] = updatedDoc.id;
    return Vehicle.fromJson(json);
  }

  Future<void> deleteVehicle(String id) async {
    await _db.collection('vehicles').doc(id).delete();
  }

  Future<TimelineEvent> updateTimelineEvent({
    required String id,
    String? title,
    String? type,
    int? mileage,
    DateTime? date,
    double? progress,
  }) async {
    final updateData = <String, Object?>{};
    if (title != null) updateData['title'] = title;
    if (type != null) updateData['type'] = type;
    if (mileage != null) updateData['mileage'] = mileage;
    if (date != null) updateData['date'] = date.toIso8601String();
    if (progress != null) updateData['progress'] = progress;

    await _db.collection('timelineEvents').doc(id).update(updateData);
    final updatedDoc = await _db.collection('timelineEvents').doc(id).get();
    final json = updatedDoc.data()!;
    json['id'] = updatedDoc.id;
    return TimelineEvent.fromJson(json);
  }

  Future<void> deleteTimelineEvent(String id) async {
    await _db.collection('timelineEvents').doc(id).delete();
  }

  Future<DistanceLog> updateDistanceLog({
    required String id,
    DateTime? date,
    double? distance,
  }) async {
    final updateData = <String, Object?>{};
    if (date != null) updateData['date'] = date.toIso8601String();
    if (distance != null) updateData['distance'] = distance;

    await _db.collection('distanceLogs').doc(id).update(updateData);
    final updatedDoc = await _db.collection('distanceLogs').doc(id).get();
    final json = updatedDoc.data()!;
    json['id'] = updatedDoc.id;
    return DistanceLog.fromJson(json);
  }

  Future<void> deleteDistanceLog(String id) async {
    await _db.collection('distanceLogs').doc(id).delete();
  }

  Future<MaintenanceRecord> updateMaintenanceRecord({
    required String id,
    String? title,
    String? status,
    DateTime? date,
  }) async {
    final updateData = <String, Object?>{};
    if (title != null) updateData['title'] = title;
    if (status != null) updateData['status'] = status;
    if (date != null) updateData['date'] = date.toIso8601String();

    await _db.collection('maintenance').doc(id).update(updateData);
    final updatedDoc = await _db.collection('maintenance').doc(id).get();
    final json = updatedDoc.data()!;
    json['id'] = updatedDoc.id;
    return MaintenanceRecord.fromJson(json);
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    await _db.collection('maintenance').doc(id).delete();
  }

  // --- Auto Seeding Engine using exact local db.json ---
  Future<void> seedFirebaseIfEmpty() async {
    try {
      debugPrint('seedFirebaseIfEmpty: checking existing vehicles');
      final existing = await _db
          .collection('vehicles')
          .limit(1)
          .get()
          .timeout(
            _firestoreTimeout,
            onTimeout: () =>
                throw StateError('Firestore seedFirebaseIfEmpty timed out'),
          );
      debugPrint('seedFirebaseIfEmpty: existing docs ${existing.docs.length}');
      if (existing.docs.isNotEmpty) return; // Already seeded

      debugPrint('seedFirebaseIfEmpty: seeding data');
      Map<String, dynamic> data = jsonDecode(_seedData);

      // Track ID mapping from old JSON static IDs to new Firestore dynamic IDs
      Map<String, String> idMap = {};

      for (var v in data['vehicles']) {
        final oldId = v['id'];
        v.remove('id');
        final docRef = await _db.collection('vehicles').add(v);
        idMap[oldId] = docRef.id;
      }

      for (var t in data['timelineEvents']) {
        t.remove('id');
        if (idMap.containsKey(t['vehicleId'])) {
          t['vehicleId'] = idMap[t['vehicleId']];
          await _db.collection('timelineEvents').add(t);
        }
      }

      for (var d in data['distanceLogs']) {
        d.remove('id');
        if (idMap.containsKey(d['vehicleId'])) {
          d['vehicleId'] = idMap[d['vehicleId']];
          await _db.collection('distanceLogs').add(d);
        }
      }

      for (var m in data['maintenance']) {
        m.remove('id');
        if (idMap.containsKey(m['vehicleId'])) {
          m['vehicleId'] = idMap[m['vehicleId']];
          await _db.collection('maintenance').add(m);
        }
      }
    } catch (e, st) {
      debugPrint('Firebase seed failed: $e');
      debugPrint(st.toString());
    }
  }

  List<Vehicle> _loadSeedVehicles() {
    final Map<String, dynamic> data =
        jsonDecode(_seedData) as Map<String, dynamic>;
    return (data['vehicles'] as List<dynamic>).map((rawVehicle) {
      final json = Map<String, dynamic>.from(rawVehicle as Map);
      return Vehicle.fromJson(json);
    }).toList();
  }

  List<TimelineEvent> _loadSeedTimelineEvents(String vehicleId) {
    final Map<String, dynamic> data =
        jsonDecode(_seedData) as Map<String, dynamic>;
    return (data['timelineEvents'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((rawEvent) => rawEvent['vehicleId'] == vehicleId)
        .map((rawEvent) => TimelineEvent.fromJson(rawEvent))
        .toList();
  }

  List<DistanceLog> _loadSeedDistanceLogs(String vehicleId) {
    final Map<String, dynamic> data =
        jsonDecode(_seedData) as Map<String, dynamic>;
    return (data['distanceLogs'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((rawLog) => rawLog['vehicleId'] == vehicleId)
        .map((rawLog) => DistanceLog.fromJson(rawLog))
        .toList();
  }

  List<MaintenanceRecord> _loadSeedMaintenanceRecords(String vehicleId) {
    final Map<String, dynamic> data =
        jsonDecode(_seedData) as Map<String, dynamic>;
    return (data['maintenance'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((rawRecord) => rawRecord['vehicleId'] == vehicleId)
        .map((rawRecord) => MaintenanceRecord.fromJson(rawRecord))
        .toList();
  }

  static const String _seedData = r'''
{
  "vehicles": [
    {
      "id": "v1",
      "name": "Tesla Model X",
      "plateNumber": "NEX 1024",
      "battery": 82.5,
      "imageUrl": "https://images.unsplash.com/photo-1560958089-b8a1929cea89?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "location": "Home Garage"
    },
    {
      "id": "v2",
      "name": "Porsche Taycan",
      "plateNumber": "EV 9001",
      "battery": 45.0,
      "imageUrl": "https://images.unsplash.com/photo-1614200187524-dc4b892acf16?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "location": "Office Parking"
    },
    {
      "id": "v3",
      "name": "Rivian R1T",
      "plateNumber": "RIV 4X4",
      "battery": 15.0,
      "imageUrl": "https://tse2.mm.bing.net/th/id/OIP.c2ZfhWnrADuO3oYBZyGkeAHaDw?rs=1&pid=ImgDetMain&o=7&rm=3",
      "location": "Charging Station"
    },
    {
      "id": "v4",
      "name": "Audi e-tron GT",
      "plateNumber": "ETR 2026",
      "battery": 68.0,
      "imageUrl": "https://tse2.mm.bing.net/th/id/OIP.fQO30cvLqez7PAiTYfPvIAHaEK?rs=1&pid=ImgDetMain&o=7&rm=3",
      "location": "Downtown Lot"
    }
  ],
  "timelineEvents": [
    {
      "id": "t1",
      "vehicleId": "v1",
      "title": "Tire Inspection",
      "type": "inspection",
      "mileage": 15000,
      "date": "2026-04-10T12:00:00.000Z",
      "progress": 0.1
    },
    {
      "id": "t2",
      "vehicleId": "v1",
      "title": "Supercharging",
      "type": "charge",
      "mileage": 14800,
      "date": "2026-04-03T12:00:00.000Z",
      "progress": 1.0
    },
    {
      "id": "t3",
      "vehicleId": "v1",
      "title": "Brake Fluid Check",
      "type": "maintenance",
      "mileage": 10000,
      "date": "2026-03-05T12:00:00.000Z",
      "progress": 1.0
    },
    {
      "id": "t4",
      "vehicleId": "v2",
      "title": "Routine Wheel Alignment",
      "type": "maintenance",
      "mileage": 7200,
      "date": "2026-04-07T09:00:00.000Z",
      "progress": 0.6
    },
    {
      "id": "t5",
      "vehicleId": "v2",
      "title": "Charging Session",
      "type": "charge",
      "mileage": 7060,
      "date": "2026-04-02T18:00:00.000Z",
      "progress": 1.0
    },
    {
      "id": "t6",
      "vehicleId": "v3",
      "title": "Software Update",
      "type": "maintenance",
      "mileage": 10500,
      "date": "2026-04-01T14:00:00.000Z",
      "progress": 1.0
    },
    {
      "id": "t7",
      "vehicleId": "v4",
      "title": "Fast Charge",
      "type": "charge",
      "mileage": 4800,
      "date": "2026-04-06T20:00:00.000Z",
      "progress": 1.0
    }
  ],
  "distanceLogs": [
    {
      "id": "d1",
      "vehicleId": "v1",
      "date": "2026-03-31T12:00:00.000Z",
      "distance": 45
    },
    {
      "id": "d2",
      "vehicleId": "v1",
      "date": "2026-04-01T12:00:00.000Z",
      "distance": 12
    },
    {
      "id": "d3",
      "vehicleId": "v1",
      "date": "2026-04-02T12:00:00.000Z",
      "distance": 80
    },
    {
      "id": "d4",
      "vehicleId": "v1",
      "date": "2026-04-03T12:00:00.000Z",
      "distance": 65
    },
    {
      "id": "d5",
      "vehicleId": "v1",
      "date": "2026-04-04T12:00:00.000Z",
      "distance": 10
    },
    {
      "id": "d6",
      "vehicleId": "v1",
      "date": "2026-04-05T12:00:00.000Z",
      "distance": 0
    },
    {
      "id": "d7",
      "vehicleId": "v1",
      "date": "2026-04-06T12:00:00.000Z",
      "distance": 30
    },
    {
      "id": "d8",
      "vehicleId": "v2",
      "date": "2026-04-01T10:00:00.000Z",
      "distance": 18
    },
    {
      "id": "d9",
      "vehicleId": "v2",
      "date": "2026-04-03T11:00:00.000Z",
      "distance": 50
    },
    {
      "id": "d10",
      "vehicleId": "v3",
      "date": "2026-04-02T08:00:00.000Z",
      "distance": 22
    },
    {
      "id": "d11",
      "vehicleId": "v4",
      "date": "2026-04-05T15:00:00.000Z",
      "distance": 74
    }
  ],
  "maintenance": [
    {
      "id": "m1",
      "vehicleId": "v1",
      "title": "Annual Service",
      "status": "Upcoming",
      "date": "2026-05-20T12:00:00.000Z"
    },
    {
      "id": "m2",
      "vehicleId": "v1",
      "title": "Software Update 4.2",
      "status": "Completed",
      "date": "2026-03-20T12:00:00.000Z"
    },
    {
      "id": "m3",
      "vehicleId": "v1",
      "title": "Cabin Filter Replacement",
      "status": "Completed",
      "date": "2025-12-05T12:00:00.000Z"
    },
    {
      "id": "m4",
      "vehicleId": "v2",
      "title": "Brake Pad Check",
      "status": "Upcoming",
      "date": "2026-04-25T09:00:00.000Z"
    },
    {
      "id": "m5",
      "vehicleId": "v3",
      "title": "Battery Health Review",
      "status": "Completed",
      "date": "2026-03-29T11:00:00.000Z"
    },
    {
      "id": "m6",
      "vehicleId": "v4",
      "title": "Tire Rotation",
      "status": "Completed",
      "date": "2026-04-04T14:00:00.000Z"
    }
  ]
}
''';
}
