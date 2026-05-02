class AppConfig {
  const AppConfig._();

  // Provide via --dart-define in CI/local builds.
  static const String mapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: '',
  );

  // Optional. If empty, app falls back to Open-Meteo.
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );

  static const String openWeatherHost = 'api.openweathermap.org';
  static const String openWeatherPath = '/data/2.5/weather';
  static const String openMeteoForecastUrl =
      'https://api.open-meteo.com/v1/forecast';

  static const String googleMapsSearchBaseUrl =
      'https://www.google.com/maps/search/';

  // Keep neutral defaults when location access is unavailable.
  static const double fallbackLatitude = 0.0;
  static const double fallbackLongitude = 0.0;

  static Uri googleMapsSearchUri({
    required double latitude,
    required double longitude,
    String? placeName,
  }) {
    return Uri.parse(googleMapsSearchBaseUrl).replace(
      queryParameters: <String, String>{
        'api': '1',
        'query': '$latitude,$longitude',
        if (placeName != null && placeName.trim().isNotEmpty)
          'query_place_id': placeName.trim(),
      },
    );
  }
}
