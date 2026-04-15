import '../services/location_service.dart';

class LocationHelper {
  LocationHelper._();

  static Future<String> readableName(double lat, double lon) {
    return LocationService.readableName(lat, lon);
  }
}
