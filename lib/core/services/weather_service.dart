import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../models/weather_snapshot.dart';

class WeatherService {
  const WeatherService._();

  static Future<WeatherSnapshot?> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final keyed = await _fetchFromOpenWeather(
      latitude: latitude,
      longitude: longitude,
    );
    if (keyed != null) {
      return keyed;
    }

    return _fetchFromOpenMeteo(latitude: latitude, longitude: longitude);
  }

  static Future<WeatherSnapshot?> _fetchFromOpenWeather({
    required double latitude,
    required double longitude,
  }) async {
    final key = AppConfig.weatherApiKey.trim();
    if (key.isEmpty) {
      return null;
    }

    final uri = Uri.https(
      AppConfig.openWeatherHost,
      AppConfig.openWeatherPath,
      {
        'lat': '$latitude',
        'lon': '$longitude',
        'appid': key,
        'units': 'imperial',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final main = body['main'] as Map<String, dynamic>?;
      final weatherList = body['weather'] as List<dynamic>?;
      if (main == null || weatherList == null || weatherList.isEmpty) {
        return null;
      }

      final weather = weatherList.first as Map<String, dynamic>?;
      final temp = (main['temp'] as num?)?.toDouble();
      final summary = (weather?['description'] as String?)?.trim();
      if (temp == null) {
        return null;
      }

      return WeatherSnapshot(
        temperature: temp,
        summary: summary == null || summary.isEmpty
            ? 'Weather update available'
            : summary,
        fetchedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<WeatherSnapshot?> _fetchFromOpenMeteo({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(AppConfig.openMeteoForecastUrl).replace(
      queryParameters: <String, String>{
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current': 'temperature_2m,weather_code',
        'temperature_unit': 'fahrenheit',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final current = body['current'] as Map<String, dynamic>?;
      if (current == null) {
        return null;
      }

      final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0;
      final code = (current['weather_code'] as num?)?.toInt() ?? 0;

      return WeatherSnapshot(
        temperature: temp,
        summary: _description(code),
        fetchedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static String _description(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 99) return 'Thunderstorms';
    return 'Weather update available';
  }
}
