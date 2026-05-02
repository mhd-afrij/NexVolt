import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';

class FirestoreTripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _tripsRef =>
      _db.collection('users').doc(_uid).collection('trips');

  // ─── Create ─────────────────────────────────────────────────

  Future<String> createTrip(TripModel trip) async {
    final now = DateTime.now();
    final data = trip.toMap()
      ..['createdAt'] = Timestamp.fromDate(now)
      ..['updatedAt'] = Timestamp.fromDate(now);

    final docRef = await _tripsRef.add(data);
    return docRef.id;
  }

  // ─── Read ────────────────────────────────────────────────────

  Stream<List<TripModel>> getTripsStream() {
    return _tripsRef
        .orderBy('tripDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Single fetch of all trips (non-streaming).
  Future<List<TripModel>> fetchTrips() async {
    final snapshot =
        await _tripsRef.orderBy('tripDate', descending: true).get();
    return snapshot.docs
        .map((doc) => TripModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch a single trip by ID.
  Future<TripModel?> getTripById(String tripId) async {
    final doc = await _tripsRef.doc(tripId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TripModel.fromMap(doc.id, doc.data()!);
  }

  // ─── Update ──────────────────────────────────────────────────

  /// Updates the status of a trip and stamps updatedAt.
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    await _tripsRef.doc(tripId).update({
      'status': status.value,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Full update of trip fields.
  Future<void> updateTrip(TripModel trip) async {
    final data = trip.toMap()
      ..['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _tripsRef.doc(trip.id).update(data);
  }

  // ─── Delete ──────────────────────────────────────────────────

  /// Permanently deletes a trip document.
  Future<void> deleteTrip(String tripId) async {
    await _tripsRef.doc(tripId).delete();
  }
}
