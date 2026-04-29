import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/weather_service.dart';
import '../../models/weather_snapshot.dart';

class WeatherApi {
  static Future<WeatherSnapshot?> fetchWeather({
    required double latitude,
    required double longitude,
  }) {
    return WeatherService.fetchWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.repository,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  final AppRepository repository;
  final double initialLatitude;
  final double initialLongitude;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  late final TextEditingController _addressController;
  WeatherSnapshot? _weather;
  String _label = 'Current location';
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(
      text: widget.initialLatitude.toStringAsFixed(4),
    );
    _lonController = TextEditingController(
      text: widget.initialLongitude.toStringAsFixed(4),
    );
    _addressController = TextEditingController();
    _refreshWeather();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshWeather(),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _addressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (location == null) return;

    _latController.text = location.latitude.toStringAsFixed(4);
    _lonController.text = location.longitude.toStringAsFixed(4);
    await _refreshWeather();
  }

  Future<void> _refreshWeather() async {
    final latitude = double.tryParse(_latController.text);
    final longitude = double.tryParse(_lonController.text);
    if (latitude == null || longitude == null) return;

    setState(() => _loading = true);

    final weather = await _fetchWeather(latitude, longitude);
    final label = await LocationService.readableName(latitude, longitude);
    await widget.repository.updateHomeLocation(
      city: label,
      latitude: latitude,
      longitude: longitude,
    );

    if (!mounted) return;
    setState(() {
      _weather = weather;
      _label = label;
      _loading = false;
    });
  }

  Future<void> _searchAddress() async {
    final query = _addressController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);
    final result = await LocationService.geocodeAddress(query);
    if (result == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Address lookup failed.')));
      return;
    }

    _latController.text = result.latitude.toStringAsFixed(6);
    _lonController.text = result.longitude.toStringAsFixed(6);
    _label = result.formattedAddress;
    await _refreshWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather & Location')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lonController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _refreshWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Update Weather'),
                      ),
                      FilledButton.icon(
                        onPressed: _searchAddress,
                        icon: const Icon(Icons.search),
                        label: const Text('Search Address'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use My Location'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weather == null
                              ? 'Unavailable'
                              : '${_weather!.temperature.toStringAsFixed(1)} F',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(_weather?.summary ?? 'No weather data available'),
                        const SizedBox(height: 6),
                        Text(
                          'Last update: ${_weather?.fetchedAt.toLocal().toString().substring(0, 19) ?? '-'}',
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<WeatherSnapshot?> _fetchWeather(double lat, double lon) async {
    return WeatherService.fetchWeather(latitude: lat, longitude: lon);
  }
}
