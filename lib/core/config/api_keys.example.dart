// API keys are now resolved via --dart-define and AppConfig.
// This file is a reference for required build-time values.

class ApiKeys {
  /// Pass in builds: --dart-define=MAPS_API_KEY=your_key
  static const String googleMapsApiKey = '';

  /// Optional. Pass: --dart-define=WEATHER_API_KEY=your_key
  static const String weatherApiKey = '';
}
