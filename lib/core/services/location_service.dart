import 'package:geolocator/geolocator.dart';

/// Handles device GPS permissions and retrieves the current location.
class LocationService {
  Future<Position> getCurrentPosition() async {
    // 1. Check if location services are enabled on the device.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable GPS on your device.',
      );
    }

    // 2. Check / request permission.
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permission denied. Please allow location access to use '
          'the Trip Planner.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission is permanently denied. '
        'Please enable it from your device settings.',
      );
    }

    // 3. Retrieve position with reasonable accuracy.
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return position;
  }

  /// Calculates the straight-line distance in kilometres between two
  /// coordinate pairs using the Geolocator package.
  double distanceBetweenKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final distanceMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceMeters / 1000.0;
  }
}

/// Custom exception for location-related errors.
class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
