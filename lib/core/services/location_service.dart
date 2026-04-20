import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

class GeocodeResult {
  const GeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.placeId,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? placeId;
}

class PlaceDetailsResult {
  const PlaceDetailsResult({required this.raw});

  final Map<String, dynamic> raw;
}

class AutocompleteResult {
  const AutocompleteResult({
    required this.placeId,
    required this.formatted,
    required this.displayName,
  });

  final String placeId;
  final String formatted;
  final String displayName;
}

class AutocompleteResponse {
  const AutocompleteResponse({required this.results});

  final List<AutocompleteResult> results;
}

class LocationService {
  static String get _geoapifyApiKey => ApiKeys.geoapifyApiKey;

  static Uri geoapifyPlaceDetailsUri({
    required String placeId,
    String? lang,
    String? features,
  }) {
    final query = <String, String>{'id': placeId, 'apiKey': _geoapifyApiKey};

    if (lang != null && lang.isNotEmpty) {
      query['lang'] = lang;
    }
    if (features != null && features.isNotEmpty) {
      query['features'] = features;
    }

    return Uri.https('api.geoapify.com', '/v2/place-details', query);
  }

  static Future<PlaceDetailsResult?> getPlaceDetails({
    required String placeId,
    String lang = 'en',
    String? features,
  }) async {
    final uri = geoapifyPlaceDetailsUri(
      placeId: placeId,
      lang: lang,
      features: features,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return PlaceDetailsResult(raw: body);
    } catch (_) {
      return null;
    }
  }

  static Future<AutocompleteResponse> getAutocomplete(String query) async {
    if (query.isEmpty) return const AutocompleteResponse(results: []);

    final uri = Uri.https('api.geoapify.com', '/v1/geocode/autocomplete', {
      'text': query,
      'apiKey': _geoapifyApiKey,
      'limit': '5',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        return const AutocompleteResponse(results: []);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>? ?? [];

      final results = features
          .whereType<Map<String, dynamic>>()
          .map((feature) {
            final props = feature['properties'] as Map<String, dynamic>? ?? {};
            return AutocompleteResult(
              placeId: props['place_id'] as String? ?? '',
              formatted: props['formatted'] as String? ?? '',
              displayName: _buildDisplayName(props),
            );
          })
          .where((r) => r.placeId.isNotEmpty)
          .toList();

      return AutocompleteResponse(results: results);
    } catch (_) {
      return const AutocompleteResponse(results: []);
    }
  }

  static String _buildDisplayName(Map<String, dynamic> props) {
    final name = props['name'] as String? ?? '';
    final city = props['city'] as String? ?? '';
    final country = props['country'] as String? ?? '';

    if (name.isEmpty) return props['formatted'] as String? ?? 'Location';

    final parts = [name];
    if (city.isNotEmpty) parts.add(city);
    if (country.isNotEmpty) parts.add(country);

    return parts.join(', ');
  }

  static Future<GeocodeResult?> geocodeAddress(String address) async {
    final uri = Uri.https('api.geoapify.com', '/v1/geocode/search', {
      'text': address,
      'apiKey': _geoapifyApiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;

      final first = features.first as Map<String, dynamic>;
      final properties = first['properties'] as Map<String, dynamic>?;
      final lat = (properties?['lat'] as num?)?.toDouble();
      final lon = (properties?['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) return null;

      final formatted =
          properties?['formatted'] as String? ??
          '${lat.toStringAsFixed(3)}, ${lon.toStringAsFixed(3)}';

      return GeocodeResult(
        latitude: lat,
        longitude: lon,
        formattedAddress: formatted,
        placeId: properties?['place_id'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> readableName(double latitude, double longitude) async {
    try {
      final places = await placemarkFromCoordinates(latitude, longitude);
      if (places.isEmpty) {
        return '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}';
      }
      final place = places.first;
      final city =
          place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
      final country = place.country ?? '';
      return '$city, $country';
    } catch (_) {
      return '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}';
    }
  }
}
