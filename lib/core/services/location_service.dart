import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeocodeResult {
  const GeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
}

class LocationService {
  static Future<GeocodeResult?> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      final first = locations.first;
      final lat = first.latitude;
      final lon = first.longitude;
      final formatted = await readableName(lat, lon);

      return GeocodeResult(
        latitude: lat,
        longitude: lon,
        formattedAddress: formatted,
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
