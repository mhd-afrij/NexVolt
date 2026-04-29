import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/trip_plan_model.dart';
import '../models/vehicle_model.dart';
import '../models/route_station_model.dart';
import '../repositories/trip_repository.dart';
import '../services/location_service.dart';
import '../services/maps_service.dart';
import '../services/trip_calculation_service.dart';

class ChargerStation {
  final String id;
  final String title;
  final String address;
  final LatLng position;
  final int numberOfPoints;
  final List<String> connectorTypes;
  final bool isOperational;

  const ChargerStation({
    required this.id,
    required this.title,
    required this.address,
    required this.position,
    required this.numberOfPoints,
    required this.connectorTypes,
    required this.isOperational,
  });

  factory ChargerStation.fromOCM(Map<String, dynamic> json) {
    final addr = json['AddressInfo'] as Map<String, dynamic>? ?? {};
    final connections = json['Connections'] as List<dynamic>? ?? [];

    final types = connections
        .map((c) =>
            (c as Map<String, dynamic>)['ConnectionType']?['Title']
                as String? ??
            'Unknown')
        .toSet()
        .toList();

    final points = connections.fold<int>(
      0,
      (sum, c) =>
          sum + (((c as Map<String, dynamic>)['Quantity'] as int?) ?? 1),
    );

    final statusId = json['StatusType']?['ID'] as int?;
    final operational = statusId == null || statusId == 50;

    return ChargerStation(
      id: json['ID'].toString(),
      title: addr['Title'] as String? ?? 'EV Charger',
      address: [
        addr['AddressLine1'],
        addr['Town'],
        addr['StateOrProvince'],
      ].where((s) => s != null && s.toString().isNotEmpty).join(', '),
      position: LatLng(
        (addr['Latitude'] as num).toDouble(),
        (addr['Longitude'] as num).toDouble(),
      ),
      numberOfPoints: points,
      connectorTypes: types,
      isOperational: operational,
    );
  }
}

enum TripLoadingState { idle, loading, success, error }

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;
  final LocationService _locationService;
  final MapsService _mapsService;
  final TripCalculationService _calcService;
  final FirebaseAuth _auth;

  static const _ocmApiKey = '';

  TripProvider({
    TripRepository? repository,
    LocationService? locationService,
    MapsService? mapsService,
    TripCalculationService? calcService,
    FirebaseAuth? auth,
  })  : _repository = repository ?? TripRepository(),
        _locationService = locationService ?? LocationService(),
        _mapsService = mapsService ?? MapsService(),
        _calcService = calcService ?? TripCalculationService(),
        _auth = auth ?? FirebaseAuth.instance;

  TripLoadingState _loadingState = TripLoadingState.idle;
  TripLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == TripLoadingState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TripPlanModel> _savedTrips = [];
  List<TripPlanModel> get savedTrips => List.unmodifiable(_savedTrips);

  List<TripPlanModel> _historyTrips = [];
  List<TripPlanModel> get historyTrips => List.unmodifiable(_historyTrips);

  List<VehicleModel> _vehicles = [];
  List<VehicleModel> get vehicles => List.unmodifiable(_vehicles);

  List<ChargerStation> _allChargers = [];
  List<ChargerStation> _filteredChargers = [];
  double _filterRadiusKm = 35.0;

  List<ChargerStation> get nearbyChargers =>
      List.unmodifiable(_filteredChargers);
  double get filterRadiusKm => _filterRadiusKm;

  VehicleModel? _selectedVehicle;
  VehicleModel? get selectedVehicle => _selectedVehicle;

  RouteStationModel? _recommendedStation;
  RouteStationModel? get recommendedStation => _recommendedStation;

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  String _startLocationName = '';
  String get startLocationName => _startLocationName;

  LatLng? _startLatLng;
  LatLng? get startLatLng => _startLatLng;

  String _destinationName = '';
  String get destinationName => _destinationName;

  LatLng? _destinationLatLng;
  LatLng? get destinationLatLng => _destinationLatLng;

  double _routeDistanceKm = 0.0;
  double get routeDistanceKm => _routeDistanceKm;

  int _estimatedDurationMinutes = 0;
  int get estimatedDurationMinutes => _estimatedDurationMinutes;

  List<LatLng> _polylinePoints = [];
  List<LatLng> get polylinePoints => List.unmodifiable(_polylinePoints);

  double _batteryRequired = 0.0;
  double get batteryRequired => _batteryRequired;

  double _batteryRemaining = 0.0;
  double get batteryRemaining => _batteryRemaining;

  bool _needsChargingStop = false;
  bool get needsChargingStop => _needsChargingStop;

  String? _preferredChargerType;
  String? get preferredChargerType => _preferredChargerType;

  TripPlanModel? _currentTripPlan;
  TripPlanModel? get currentTripPlan => _currentTripPlan;

  /*String get _userId {
    final user = _auth.currentUser;
    return user?.uid ?? 'test_user_001';
  }*/
  String get _userId {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception('User not initialized');
  }

  return user.uid;
}

  void _setLoading() {
    _loadingState = TripLoadingState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = TripLoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess() {
    _loadingState = TripLoadingState.success;
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    _setLoading();
    try {
      _vehicles = await _repository.getUserVehicles(_userId);
      if (_vehicles.isNotEmpty && _selectedVehicle == null) {
        _selectedVehicle = _vehicles.first;
      }
      _setSuccess();
    } catch (e) {
      _setError('Could not load vehicles. Please try again.');
    }
  }

  Future<void> loadSavedTrips() async {
    _setLoading();
    try {
      _savedTrips = await _repository.getSavedTrips(_userId);
      _setSuccess();
    } catch (e) {
      _setError('Could not load saved trips.');
    }
  }

  Future<void> loadTripHistory() async {
    _setLoading();
    try {
      _historyTrips = await _repository.getTripHistory(_userId);
      _setSuccess();
    } catch (e) {
      _setError('Could not load trip history.');
    }
  }

  void setSelectedVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void setPreferredChargerType(String? type) {
    _preferredChargerType = type;
    notifyListeners();
  }

  Future<void> detectCurrentLocation() async {
    _setLoading();
    try {
      final position = await _locationService.getCurrentPosition();

      _currentLocation = LatLng(position.latitude, position.longitude);
      _startLatLng = _currentLocation;

      _startLocationName = await _mapsService.reverseGeocode(_currentLocation!);

      if (_startLocationName.isEmpty) {
        _startLocationName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      _setSuccess();
    } catch (e) {
      _setError(e.toString().replaceAll('LocationServiceException: ', ''));
    }
  }

  Future<bool> setStartLocation(String locationName) async {
    _setLoading();
    try {
      final latLng = await _mapsService.geocodeAddress(locationName);

      if (latLng == null) {
        _setError(
          'Could not find "$locationName". Please try a different address.',
        );
        return false;
      }

      _startLatLng = latLng;
      _startLocationName = locationName;
      _setSuccess();
      return true;
    } catch (e) {
      _setError('Failed to locate start address.');
      return false;
    }
  }

  Future<bool> setDestination(String locationName) async {
    _setLoading();
    try {
      final latLng = await _mapsService.geocodeAddress(locationName);

      if (latLng == null) {
        _setError(
          'Could not find "$locationName". Please try a different address.',
        );
        return false;
      }

      _destinationLatLng = latLng;
      _destinationName = locationName;
      _setSuccess();
      return true;
    } catch (e) {
      _setError('Failed to locate destination address.');
      return false;
    }
  }

  Future<void> fetchNearbyChargers({
  required LatLng center,
  required double radiusKm,
  String? connectorType,
}) async {
  const connectorTypeIds = {
    'Type 2': '25',
    'CCS': '33',
    'CHAdeMO': '2',
    'GB/T': '27',
  };
 
  final typeParam =
      connectorType != null && connectorTypeIds.containsKey(connectorType)
          ? '&connectiontypeid=${connectorTypeIds[connectorType]}'
          : '';
 
  final url = Uri.parse(
    'https://api.openchargemap.io/v3/poi'
    '?output=json'
    '&latitude=${center.latitude}'
    '&longitude=${center.longitude}'
    '&distance=$radiusKm'
    '&distanceunit=KM'
    '&maxresults=150'
    '&compact=true'
    '&verbose=false'
    '$typeParam',
    // ✅ KEY REMOVED from URL — sent as header instead
  );
 
  try {
    final response = await http.get(
      url,
      headers: {
        // ✅ OCM requires the key in the X-API-Key header to avoid bot detection
        'X-API-Key': _ocmApiKey,
        'Accept': 'application/json',
        'User-Agent': 'NextVolt-EV-App/1.0',
      },
    );
 
    debugPrint('OCM status code: ${response.statusCode}');
 
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _allChargers = data.map((json) => ChargerStation.fromOCM(json)).toList();
      _filteredChargers = List.from(_allChargers);
      debugPrint('OCM chargers fetched: ${_allChargers.length}');
      notifyListeners();
    } else {
      debugPrint('OCM API error: ${response.statusCode}');
      debugPrint('OCM response: ${response.body}');
    }
  } catch (e) {
    debugPrint('OCM fetch error: $e');
  }
}

  void filterNearbyChargers({required double radiusKm}) {
    _filterRadiusKm = radiusKm;

    if (_currentLocation == null) {
      notifyListeners();
      return;
    }

    _filteredChargers = _allChargers.where((station) {
      return _haversineKm(_currentLocation!, station.position) <= radiusKm;
    }).toList();

    notifyListeners();
  }

  int countChargersAlongRoute({double thresholdKm = 10.0}) {
    if (_polylinePoints.isEmpty || _filteredChargers.isEmpty) return 0;

    return _filteredChargers.where((station) {
      return _polylinePoints.any(
        (point) => _haversineKm(point, station.position) <= thresholdKm,
      );
    }).length;
  }

  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;

    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;

    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;

    final aa = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(
      math.sqrt(aa),
      math.sqrt(1 - aa),
    );

    return r * c;
  }

  Future<bool> calculateTrip() async {
    if (_startLatLng == null || _startLocationName.isEmpty) {
      _setError('Please enter or detect a start location.');
      return false;
    }

    if (_destinationLatLng == null || _destinationName.isEmpty) {
      _setError('Please enter a destination.');
      return false;
    }

    if (_startLocationName.trim().toLowerCase() ==
        _destinationName.trim().toLowerCase()) {
      _setError('Start location and destination cannot be the same.');
      return false;
    }

    if (_selectedVehicle == null) {
      _setError('Please select a vehicle to continue.');
      return false;
    }

    _setLoading();

    try {
      final route = await _mapsService.getRoute(
        origin: _startLatLng!,
        destination: _destinationLatLng!,
      );

      _routeDistanceKm = route.distanceKm;
      _estimatedDurationMinutes = route.durationMinutes;
      _polylinePoints = route.polylinePoints;

      if (_routeDistanceKm <= 0) {
        _setError('Unable to calculate route. Please check your locations.');
        return false;
      }

      if (_polylinePoints.isNotEmpty) {
        final midPoint = _polylinePoints[_polylinePoints.length ~/ 2];

        await fetchNearbyChargers(
          center: midPoint,
          radiusKm: 50,
          connectorType: _preferredChargerType,
        );

        debugPrint('Polyline points: ${_polylinePoints.length}');
        debugPrint('Chargers fetched: ${_filteredChargers.length}');
        debugPrint('Chargers on route: ${countChargersAlongRoute()}');
      }

      final calc = _calcService.calculateBattery(
        distanceKm: _routeDistanceKm,
        vehicle: _selectedVehicle!,
      );

      _batteryRequired = calc.batteryRequiredPercent;
      _batteryRemaining = calc.remainingBatteryPercent;
      _needsChargingStop = calc.needsChargingStop;

      _recommendedStation = null;

      if (_needsChargingStop) {
        final stations = await _repository.getStations();

        _recommendedStation = _calcService.recommendStation(
          allStations: stations,
          routeStart: _startLatLng!,
          routeEnd: _destinationLatLng!,
          preferredConnectorType:
              _preferredChargerType ?? _selectedVehicle!.connectorType,
        );
      }

      _setSuccess();
      return true;
    } catch (e) {
      debugPrint('Trip calculation error: $e');
      _setError('Trip calculation failed. Please try again.');
      return false;
    }
  }

  Future<TripPlanModel?> saveTrip() async {
    if (_startLatLng == null ||
        _destinationLatLng == null ||
        _selectedVehicle == null) {
      _setError('No trip data to save. Please calculate a trip first.');
      return null;
    }

    _setLoading();

    try {
      final tripId = const Uuid().v4();

      final trip = TripPlanModel(
        tripId: tripId,
        userId: _userId,
        vehicleId: _selectedVehicle!.vehicleId,
        startLocationName: _startLocationName,
        destinationName: _destinationName,
        startLatitude: _startLatLng!.latitude,
        startLongitude: _startLatLng!.longitude,
        destinationLatitude: _destinationLatLng!.latitude,
        destinationLongitude: _destinationLatLng!.longitude,
        distanceKm: _routeDistanceKm,
        estimatedDurationMinutes: _estimatedDurationMinutes,
        batteryAtStart: _selectedVehicle!.currentBatteryPercentage,
        estimatedBatteryRequired: _batteryRequired,
        estimatedBatteryRemaining: _batteryRemaining,
        needsChargingStop: _needsChargingStop,
        recommendedStationId: _recommendedStation?.stationId,
        recommendedStationName: _recommendedStation?.name,
        selectedChargerType:
            _preferredChargerType ?? _selectedVehicle!.connectorType,
        status: 'saved',
        createdAt: DateTime.now(),
        tripDate: DateTime.now(),
      );

      final saved = await _repository.createTripPlan(trip);

      _currentTripPlan = saved;
      _savedTrips = [saved, ..._savedTrips];

      _setSuccess();
      return saved;
    } catch (e) {
      _setError('Failed to save trip. Please try again.');
      return null;
    }
  }

  Future<void> startTrip(String tripId) async {
    _setLoading();

    try {
      await _repository.updateTripStatus(tripId, 'started');
      _updateLocalStatus(tripId, 'started');
      _setSuccess();
    } catch (e) {
      _setError('Could not start trip.');
    }
  }

  Future<void> completeTrip(String tripId) async {
    _setLoading();

    try {
      await _repository.completeTrip(tripId);

      final index = _savedTrips.indexWhere((t) => t.tripId == tripId);

      if (index != -1) {
        final completed = _savedTrips[index].copyWith(
          status: 'completed',
          completedAt: DateTime.now(),
        );

        _savedTrips.removeAt(index);
        _historyTrips = [completed, ..._historyTrips];
      }

      _setSuccess();
    } catch (e) {
      _setError('Could not complete trip.');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _setLoading();

    try {
      await _repository.deleteTrip(tripId);
      _savedTrips.removeWhere((t) => t.tripId == tripId);
      _historyTrips.removeWhere((t) => t.tripId == tripId);
      _setSuccess();
    } catch (e) {
      _setError('Could not delete trip.');
    }
  }

  void resetPlanner() {
    _startLocationName = '';
    _startLatLng = null;
    _destinationName = '';
    _destinationLatLng = null;
    _routeDistanceKm = 0.0;
    _estimatedDurationMinutes = 0;
    _polylinePoints = [];
    _batteryRequired = 0.0;
    _batteryRemaining = 0.0;
    _needsChargingStop = false;
    _recommendedStation = null;
    _currentTripPlan = null;
    _preferredChargerType = null;
    _loadingState = TripLoadingState.idle;
    _errorMessage = null;

    notifyListeners();
  }

  void _updateLocalStatus(String tripId, String newStatus) {
    final savedIdx = _savedTrips.indexWhere((t) => t.tripId == tripId);

    if (savedIdx != -1) {
      final updated = _savedTrips[savedIdx].copyWith(status: newStatus);
      _savedTrips[savedIdx] = updated;
    }
  }
}
