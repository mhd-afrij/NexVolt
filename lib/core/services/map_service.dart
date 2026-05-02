import 'dart:convert';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Result returned by [MapsService.getRoute].
class RouteResult {
  final double distanceKm;
  final int durationMinutes;
  final List<LatLng> polylinePoints;

  const RouteResult({
    required this.distanceKm,
    required this.durationMinutes,
    required this.polylinePoints,
  });
}

/// Handles geocoding, reverse-geocoding, and route calculations.
///
/// For production: replace [_googleMapsApiKey] with your real key from
/// https://console.cloud.google.com and enable the Directions API.
class MapsService {
  // ⚠️  CONFIGURE YOUR API KEY HERE
  static const String _googleMapsApiKey = '';

  final PolylinePoints _polylinePoints = PolylinePoints();

  /// Converts a human-readable address string into [LatLng] coordinates.
  ///
  /// Returns `null` if the location could not be geocoded.
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (e) {
      // Geocoding failed – caller should show a user-friendly error.
      return null;
    }
  }

  /// Reverse-geocodes [LatLng] coordinates into a human-readable address.
  ///
  /// Returns a formatted string or an empty string on failure.
  Future<String> reverseGeocode(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return '';
      final p = placemarks.first;
      final parts = <String>[
        if (p.name != null && p.name!.isNotEmpty) p.name!,
        if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
          p.administrativeArea!,
      ];
      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  /// Fetches route distance, duration, and polyline between two points.
  ///
  /// Uses the Google Directions REST API when a valid key is configured.
  /// Falls back to a straight-line haversine estimate when the key is
  /// the placeholder string.
  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // ── Fallback: straight-line estimate (no API key) ─────────────────
    if (_googleMapsApiKey.isEmpty ||
        _googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      return _fallbackRoute(origin, destination);
    }

    // ── Google Directions API call ────────────────────────────────────
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_googleMapsApiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        return _fallbackRoute(origin, destination);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('Directions API status: ${data['status']}');
      debugPrint('Directions API error: ${data['error_message']}');
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return _fallbackRoute(origin, destination);
      }

      final leg = routes[0]['legs'][0] as Map<String, dynamic>;
      final distanceMeters = (leg['distance']['value'] as num).toDouble();
      final durationSeconds = (leg['duration']['value'] as num).toInt();

      // Decode polyline from the overview_polyline field.
      final encodedPolyline =
          routes[0]['overview_polyline']['points'] as String;
      final decoded = _polylinePoints.decodePolyline(encodedPolyline);
      final latLngList = decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      return RouteResult(
        distanceKm: distanceMeters / 1000.0,
        durationMinutes: (durationSeconds / 60).round(),
        polylinePoints: latLngList,
      );
    } catch (_) {
      return _fallbackRoute(origin, destination);
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────

  /// Haversine straight-line fallback when no Directions API key exists.
  /// Applies a 1.35× road-distance factor as a rough approximation.
  RouteResult _fallbackRoute(LatLng origin, LatLng destination) {
    final straightLineKm = _haversineKm(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    final roadKm = straightLineKm * 1.35;
    final durationMinutes = (roadKm / 60 * 60).round(); // ~60 km/h avg

    // Simple two-point polyline for display purposes.
    return RouteResult(
      distanceKm: roadKm,
      durationMinutes: durationMinutes,
      polylinePoints: [origin, destination],
    );
  }

  /// Haversine formula: returns distance in km between two lat/lng pairs.
  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * pi / 180.0;
}
