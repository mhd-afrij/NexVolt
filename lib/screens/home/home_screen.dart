import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/location_service.dart';
import '../../models/station_model.dart';
import '../../models/vehicle_model.dart';
import '../booking/booking_screen.dart';
import '../garage/garage_screen.dart';
import '../planner/trip_planner_screen.dart';
import '../profile/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../station/map_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    this.startupWarning,
    required this.enableMaps,
    this.initialTab = 0,
  });

  final AppRepository repository;
  final String? startupWarning;
  final bool enableMaps;
  final int initialTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab.clamp(0, 4);
  }

  void _goToTab(int value) {
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardScreen(
        repository: widget.repository,
        startupWarning: widget.startupWarning,
        enableMaps: widget.enableMaps,
        onGoToGarage: () => _goToTab(2),
      ),
      const TripPlannerScreen(),
      GarageScreen(repository: widget.repository),
      const BookingScreen(),
      ProfileScreen(repository: widget.repository),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 25,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _goToTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.alt_route_outlined),
                selectedIcon: Icon(Icons.alt_route),
                label: 'Planner',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_car_outlined),
                selectedIcon: Icon(Icons.directions_car),
                label: 'Garage',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: 'Booking',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen({
    required this.repository,
    required this.onGoToGarage,
    this.startupWarning,
    required this.enableMaps,
  });

  final AppRepository repository;
  final VoidCallback onGoToGarage;
  final String? startupWarning;
  final bool enableMaps;

  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  WeatherSnapshot? _weather;
  String _locationLabel = 'Detecting location';
  LatLng _currentLatLng = const LatLng(6.9271, 79.8612);
  bool _loadingWeather = true;

  String _resolveWelcomeName(Map<String, dynamic> profile) {
    final first = (profile['firstName'] as String?)?.trim();
    final last = (profile['lastName'] as String?)?.trim();
    final combined = [first, last]
        .whereType<String>()
        .where((v) => v.isNotEmpty && v.toLowerCase() != 'null')
        .join(' ')
        .trim();
    if (combined.isNotEmpty) return combined;

    final direct = (profile['name'] as String?)?.trim();
    if (direct != null && direct.isNotEmpty && direct.toLowerCase() != 'null') {
      return direct;
    }

    final displayName = (profile['displayName'] as String?)?.trim();
    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName.toLowerCase() != 'null') {
      return displayName;
    }

    final email = (profile['email'] as String?)?.trim();
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty && localPart.toLowerCase() != 'null') {
        return localPart;
      }
    }

    final phone = (profile['phone'] as String?)?.trim();
    if (phone != null && phone.isNotEmpty && phone.toLowerCase() != 'null') {
      return phone;
    }

    return 'Driver';
  }

  @override
  void initState() {
    super.initState();
    _loadLocationAndWeather();
  }

  Future<void> _loadLocationAndWeather() async {
    if (!mounted) return;
    setState(() => _loadingWeather = true);

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        _currentLatLng = LatLng(location.latitude, location.longitude);
        _locationLabel = await LocationService.readableName(
          location.latitude,
          location.longitude,
        );
      }

      final weather = await _WeatherService.fetchWeather(
        latitude: _currentLatLng.latitude,
        longitude: _currentLatLng.longitude,
      );

      if (!mounted) return;
      setState(() {
        _weather = weather;
        _loadingWeather = false;
      });
    } catch (e) {
      debugPrint('Home load failed: $e');
      if (!mounted) return;
      setState(() {
        _weather = null;
        _locationLabel = 'Location unavailable';
        _loadingWeather = false;
      });
    }
  }

  Color _batteryColor(int value) {
    if (value < 20) return AppColors.batteryLow;
    if (value <= 50) return AppColors.batteryMedium;
    return AppColors.batteryHigh;
  }

  @override
  Widget build(BuildContext context) {
    void openMapExplorer() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MapScreen(
            repository: widget.repository,
            initialLocation: _currentLatLng,
            enableMaps: widget.enableMaps,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLocationAndWeather,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        children: [
          if (widget.startupWarning != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.startupWarning!,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          StreamBuilder<Map<String, dynamic>>(
            stream: widget.repository.watchProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data ?? const <String, dynamic>{};
              final name = _resolveWelcomeName(profile);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.backgroundTop, AppColors.cardBackground],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.75),
                          width: 2,
                        ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26344A), Color(0xFF1A2435)],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                              children: [
                                const TextSpan(text: 'Welcome '),
                                TextSpan(
                                  text: name,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfileScreen(repository: widget.repository),
                        ),
                      ),
                      icon: const Icon(Icons.tune, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: widget.onGoToGarage,
            child: _CardBox(
              borderColor: AppColors.primary.withValues(alpha: 0.5),
              glowColor: AppColors.primary.withValues(alpha: 0.2),
              child: StreamBuilder<List<VehicleModel>>(
                stream: widget.repository.watchVehicles(),
                builder: (context, snapshot) {
                  final vehicle = snapshot.data?.isNotEmpty == true
                      ? snapshot.data!.first
                      : const VehicleModel(
                          model: 'No Vehicle',
                          plate: 'Not set',
                          batteryPercent: 0,
                        );
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.model,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle.plate,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Battery: ${vehicle.batteryPercent}%',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: (vehicle.batteryPercent / 100).clamp(
                                  0.0,
                                  1.0,
                                ),
                                minHeight: 9,
                                backgroundColor:
                                    AppColors.cardBackgroundElevated,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _batteryColor(vehicle.batteryPercent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 104,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.electric_car,
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WeatherScreen(
                        repository: widget.repository,
                        initialLatitude: _currentLatLng.latitude,
                        initialLongitude: _currentLatLng.longitude,
                      ),
                    ),
                  ),
                  child: _CardBox(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF172436)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _locationLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_loadingWeather)
                          const CircularProgressIndicator(strokeWidth: 2)
                        else
                          Text(
                            _weather == null
                                ? 'Weather unavailable'
                                : '${_weather!.temperature.toStringAsFixed(1)} F',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          _weather?.summary ?? 'Tap for real-time forecast',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FavoritesScreen(repository: widget.repository),
                    ),
                  ),
                  child: _CardBox(
                    backgroundColor: AppColors.cardBackgroundElevated,
                    child: StreamBuilder<List<StationModel>>(
                      stream: widget.repository.watchFavoriteStations(),
                      builder: (context, snapshot) {
                        final station = snapshot.data?.isNotEmpty == true
                            ? snapshot.data!.first
                            : null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: AppColors.star,
                                ),
                                SizedBox(width: 6),
                                Text('Favorite Station'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              station?.name ?? 'Not selected',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              station?.address ?? 'Tap to manage',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.17),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Text(
                                '${station?.distanceKm.toStringAsFixed(1) ?? '0.0'} miles',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CardBox(
            borderColor: AppColors.accent.withValues(alpha: 0.45),
            glowColor: AppColors.accent.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Map Explorer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: openMapExplorer,
                      icon: const Icon(Icons.fullscreen),
                      label: const Text('Maximize'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: openMapExplorer,
                  child: SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: widget.enableMaps
                                ? GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _currentLatLng,
                                      zoom: 13,
                                    ),
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('preview-me'),
                                        position: _currentLatLng,
                                        infoWindow: const InfoWindow(
                                          title: 'You are here',
                                        ),
                                      ),
                                    },
                                  )
                                : Container(
                                    color: AppColors.weatherCard,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Map preview unavailable on web build',
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Column(
                              children: [
                                FloatingActionButton.small(
                                  heroTag: 'map-open',
                                  backgroundColor: AppColors.primary,
                                  onPressed: openMapExplorer,
                                  child: const Icon(Icons.open_in_full),
                                ),
                                const SizedBox(height: 8),
                                FloatingActionButton.small(
                                  heroTag: 'map-refresh',
                                  backgroundColor: AppColors.accent,
                                  onPressed: _loadLocationAndWeather,
                                  child: const Icon(Icons.my_location),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.gradient,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppColors.cardBackground)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: glowColor ?? const Color(0x4D000000),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WeatherService {
  static Future<WeatherSnapshot?> fetchWeather({
    required double latitude,
    required double longitude,
  }) {
    return WeatherApi.fetchWeather(latitude: latitude, longitude: longitude);
  }
}
