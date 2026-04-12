import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/location_service.dart';
import '../../models/station_model.dart';
import '../../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.repository,
    required this.initialLocation,
    required this.enableMaps,
  });

  final AppRepository repository;
  final LatLng initialLocation;
  final bool enableMaps;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _anim300 = Duration(milliseconds: 300);

  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<List<StationModel>>? _stationSubscription;
  LatLng? _currentPosition;
  Marker? _searchMarker;
  String? _searchedAddress;
  bool _isSearching = false;
  bool _showSuggestions = false;
  List<AutocompleteResult> _suggestions = [];
  List<StationModel> _stations = const [];
  Set<Marker> _stationMarkers = <Marker>{};

  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0b1220"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0b1220"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#94a3b8"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1f2937"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#111827"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0b2a3f"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialLocation;
    _trackLiveLocation();
    _watchStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationSubscription?.cancel();
    _stationSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final response = await LocationService.getAutocomplete(query);
    if (!mounted) return;
    setState(() {
      _suggestions = response.results;
      _showSuggestions = _suggestions.isNotEmpty;
    });
  }

  Future<void> _selectSuggestion(AutocompleteResult suggestion) async {
    _searchController.text = suggestion.displayName;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });

    await _searchAndMovePlaceId(suggestion.placeId);
  }

  Future<void> _searchAndMovePlaceId(String placeId) async {
    if (placeId.isEmpty || _isSearching) return;

    setState(() => _isSearching = true);

    final details = await LocationService.getPlaceDetails(
      placeId: placeId,
      features: 'details',
    );

    if (!mounted) return;

    if (details == null) {
      setState(() => _isSearching = false);
      return;
    }

    final feature = (details.raw['features'] as List<dynamic>?)?.firstOrNull;
    final featureProps = feature is Map<String, dynamic>
        ? feature['properties'] as Map<String, dynamic>?
        : null;

    final lat = (featureProps?['lat'] as num?)?.toDouble();
    final lon = (featureProps?['lon'] as num?)?.toDouble();
    final formatted = featureProps?['formatted'] as String? ?? '';

    if (lat == null || lon == null) {
      setState(() => _isSearching = false);
      return;
    }

    final target = LatLng(lat, lon);

    if (!mounted) return;
    setState(() {
      _currentPosition = target;
      _searchedAddress = formatted.isNotEmpty ? formatted : 'Selected location';
      _searchMarker = Marker(
        markerId: const MarkerId('searched-location'),
        position: target,
        infoWindow: InfoWindow(
          title: 'Selected location',
          snippet: _searchedAddress,
        ),
      );
      _isSearching = false;
    });

    await _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
  }

  Future<void> _searchAndMove(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty || _isSearching) return;

    setState(() => _isSearching = true);

    final geocoded = await LocationService.geocodeAddress(query);
    if (!mounted) return;

    if (geocoded == null) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found. Try another query.')),
      );
      return;
    }

    var label = geocoded.formattedAddress;
    final placeId = geocoded.placeId;
    if (placeId != null && placeId.isNotEmpty) {
      final details = await LocationService.getPlaceDetails(
        placeId: placeId,
        features: 'details',
      );

      final feature = (details?.raw['features'] as List<dynamic>?)?.firstOrNull;
      final properties = feature is Map<String, dynamic>
          ? feature['properties'] as Map<String, dynamic>?
          : null;
      final detailedAddress = properties?['formatted'] as String?;
      if (detailedAddress != null && detailedAddress.isNotEmpty) {
        label = detailedAddress;
      }
    }

    final target = LatLng(geocoded.latitude, geocoded.longitude);
    _searchController.text = query;

    if (!mounted) return;
    setState(() {
      _currentPosition = target;
      _searchedAddress = label;
      _searchMarker = Marker(
        markerId: const MarkerId('searched-location'),
        position: target,
        infoWindow: InfoWindow(title: 'Selected location', snippet: label),
      );
      _isSearching = false;
    });

    await _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
  }

  Future<void> _trackLiveLocation() async {
    final current = await LocationService.getCurrentLocation();
    if (current != null && mounted) {
      setState(() {
        _currentPosition = LatLng(current.latitude, current.longitude);
      });
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 20,
          ),
        ).listen((position) {
          if (!mounted) return;
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        });
  }

  void _watchStations() {
    _stationSubscription = widget.repository.watchFavoriteStations().listen((
      stations,
    ) {
      _stations = stations;
      final markers = stations
          .map(
            (s) => Marker(
              markerId: MarkerId(s.id),
              position: LatLng(s.latitude, s.longitude),
              infoWindow: InfoWindow(title: s.name, snippet: s.address),
            ),
          )
          .toSet();

      if (!mounted) return;
      setState(() => _stationMarkers = markers);
    });
  }

  StationModel? get _highlightStation {
    if (_stations.isEmpty) {
      return null;
    }

    final current = _currentPosition;
    if (current == null) {
      return _stations.first;
    }

    StationModel nearest = _stations.first;
    var nearestDistance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      nearest.latitude,
      nearest.longitude,
    );

    for (final station in _stations.skip(1)) {
      final distance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        station.latitude,
        station.longitude,
      );
      if (distance < nearestDistance) {
        nearest = station;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  Future<void> _centerOnCurrentLocation() async {
    final location = _currentPosition ?? widget.initialLocation;
    await _controller?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
  }

  @override
  Widget build(BuildContext context) {
    final location = _currentPosition ?? widget.initialLocation;
    final myMarker = Marker(
      markerId: const MarkerId('live-user'),
      position: location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'My live location'),
    );
    final station = _highlightStation;

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: _anim300,
                      curve: Curves.easeOutCubic,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.24),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: _onSearchChanged,
                        onSubmitted: _searchAndMove,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search location',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          suffixIcon: IconButton(
                            tooltip: 'Search',
                            onPressed: _isSearching
                                ? null
                                : () => _searchAndMove(_searchController.text),
                            icon: _isSearching
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_forward,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundElevated.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.26),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _centerOnCurrentLocation,
                      iconSize: 20,
                      icon: const Icon(Icons.tune, color: AppColors.primary),
                      tooltip: 'Filters',
                    ),
                  ),
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackgroundElevated.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            title: Text(
                              suggestion.displayName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              suggestion.formatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: _anim300,
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.35),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99000000),
                            blurRadius: 36,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: widget.enableMaps
                            ? GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: location,
                                  zoom: 13.5,
                                ),
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                markers: {
                                  ..._stationMarkers,
                                  myMarker,
                                  if (_searchMarker != null) _searchMarker!,
                                },
                                onMapCreated: (c) {
                                  _controller = c;
                                  c.setMapStyle(_darkMapStyle);
                                },
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.cardBackground,
                                      AppColors.backgroundTop,
                                    ],
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Map preview unavailable on this platform',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Column(
                        children: [
                          _GlowCircleButton(
                            heroTag: 'map-locate',
                            icon: Icons.my_location,
                            color: AppColors.accent,
                            shadowColor: AppColors.accent.withValues(
                              alpha: 0.6,
                            ),
                            onTap: _centerOnCurrentLocation,
                          ),
                          const SizedBox(height: 10),
                          _GlowCircleButton(
                            heroTag: 'map-qr',
                            icon: Icons.qr_code_scanner,
                            color: AppColors.primary,
                            shadowColor: AppColors.primary.withValues(
                              alpha: 0.8,
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.qrScanner,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.stationDetails,
                  arguments: StationDetailsArgs(
                    station: station,
                    mainTabIndex: 0,
                  ),
                ),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: _anim300,
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundElevated.withValues(
                      alpha: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x80000000),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: station == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            'Station Details\nNo nearby favorite stations yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  station.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              station.address,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 15,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${station.distanceKm.toStringAsFixed(1)} miles away',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (_searchedAddress != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Selected: $_searchedAddress',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                _InfoChip(
                                  icon: Icons.event_available,
                                  label: '3 slots available',
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                _InfoChip(
                                  icon: Icons.flash_on,
                                  label: '150 kW fast',
                                  color: AppColors.accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowCircleButton extends StatelessWidget {
  const _GlowCircleButton({
    required this.heroTag,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  final String heroTag;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: color,
      elevation: 0,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 18, spreadRadius: 1),
          ],
        ),
        child: Icon(icon, color: AppColors.backgroundTop),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
