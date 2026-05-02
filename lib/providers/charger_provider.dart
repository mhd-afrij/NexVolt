import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextvolitemp/trip_planner/models/charger_model.dart';

class ChargerProvider extends ChangeNotifier {
  List<ChargerModel> chargers = [];
  Set<Marker> markers = {};

  Future<void> loadChargers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('chargers').get();

    chargers = snapshot.docs.map((doc) {
      return ChargerModel.fromMap(doc.data(), doc.id);
    }).toList();

    markers = chargers.map((c) {
      return Marker(
        markerId: MarkerId(c.id),
        position: LatLng(c.latitude, c.longitude),
        infoWindow: InfoWindow(
          title: c.name,
          snippet: c.chargerType,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        onTap: () {
          selectedCharger = c;
          notifyListeners();
        },
      );
    }).toSet();

    notifyListeners();
  }

  ChargerModel? selectedCharger;
}
