import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/station_model.dart';
import '../models/route_station_model.dart';
import '../models/vehicle_model.dart';

/// Result of a trip battery calculation.
class TripCalculationResult {
  /// Energy required for the trip in kWh.
  final double energyRequiredKWh;

  /// Energy available in the battery at departure in kWh.
  final double availableEnergyKWh;

  /// Estimated remaining energy after the trip in kWh.
  final double remainingEnergyKWh;

  /// Estimated remaining battery percentage after the trip.
  final double remainingBatteryPercent;

  /// Battery percentage required for this trip (0–100).
  final double batteryRequiredPercent;

  /// Whether a charging stop is recommended.
  final bool needsChargingStop;

  const TripCalculationResult({
    required this.energyRequiredKWh,
    required this.availableEnergyKWh,
    required this.remainingEnergyKWh,
    required this.remainingBatteryPercent,
    required this.batteryRequiredPercent,
    required this.needsChargingStop,
  });
}

/// Pure business-logic service for EV trip calculations and
/// charging station recommendations.
///
/// No UI or Firebase dependencies — fully testable in isolation.
class TripCalculationService {
  /// Safety reserve threshold (15 % of battery capacity).
  static const double safetyReservePercent = 15.0;

  // ─────────────────────────────────────────────────────────────────────
  // Battery calculation
  // ─────────────────────────────────────────────────────────────────────

  /// Calculates battery usage and whether a charging stop is needed.
  ///
  /// [distanceKm]   – route distance in kilometres.
  /// [vehicle]      – the selected vehicle with efficiency and battery data.
  TripCalculationResult calculateBattery({
    required double distanceKm,
    required VehicleModel vehicle,
  }) {
    // Energy required = distance × efficiency (kWh/km)
    final energyRequiredKWh =
        distanceKm * vehicle.efficiencyKWhPerKm;

    // Available energy = capacity × current SOC percentage
    final availableEnergyKWh =
        vehicle.batteryCapacityKWh * (vehicle.currentBatteryPercentage / 100.0);

    // Remaining energy after trip
    final remainingEnergyKWh = availableEnergyKWh - energyRequiredKWh;

    // Remaining battery percentage
    final remainingBatteryPercent =
        (remainingEnergyKWh / vehicle.batteryCapacityKWh) * 100.0;

    // Percentage of battery capacity required for this trip
    final batteryRequiredPercent =
        (energyRequiredKWh / vehicle.batteryCapacityKWh) * 100.0;

    // A charging stop is needed if remaining battery falls below the reserve.
    final needsChargingStop =
        remainingBatteryPercent < safetyReservePercent;

    return TripCalculationResult(
      energyRequiredKWh: energyRequiredKWh,
      availableEnergyKWh: availableEnergyKWh,
      remainingEnergyKWh: remainingEnergyKWh.clamp(
        -vehicle.batteryCapacityKWh,
        vehicle.batteryCapacityKWh,
      ),
      remainingBatteryPercent: remainingBatteryPercent.clamp(-100.0, 100.0),
      batteryRequiredPercent: batteryRequiredPercent.clamp(0.0, 200.0),
      needsChargingStop: needsChargingStop,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Station recommendation
  // ─────────────────────────────────────────────────────────────────────

  /// Returns the best recommended [RouteStationModel] from [allStations],
  /// or `null` if none is suitable.
  ///
  /// Selection criteria (in order):
  ///   1. Station must be active.
  ///   2. Station must have available slots (> 0).
  ///   3. Station charger types must include [preferredConnectorType]
  ///      (if provided).
  ///   4. The closest station to the route midpoint is chosen.
  RouteStationModel? recommendStation({
    required List<StationModel> allStations,
    required LatLng routeStart,
    required LatLng routeEnd,
    String? preferredConnectorType,
  }) {
    // Compute the geographical midpoint of the route.
    final midpoint = _midpoint(routeStart, routeEnd);

    // Filter stations.
    final candidates = allStations.where((s) {
      if (!s.isActive) return false;
      if (s.availableSlots <= 0) return false;
      if (preferredConnectorType != null &&
          preferredConnectorType.isNotEmpty) {
        final match = s.chargerTypes.any(
          (t) =>
              t.toLowerCase() == preferredConnectorType.toLowerCase(),
        );
        if (!match) return false;
      }
      return true;
    }).toList();

    if (candidates.isEmpty) return null;

    // Score each candidate by distance from midpoint.
    final scored = candidates.map((s) {
      final dist = _haversineKm(
        midpoint.latitude,
        midpoint.longitude,
        s.latitude,
        s.longitude,
      );
      return RouteStationModel(
        stationId: s.stationId,
        name: s.name,
        position: LatLng(s.latitude, s.longitude),
        chargerTypes: s.chargerTypes,
        availableSlots: s.availableSlots,
        distanceFromRouteMidpointKm: dist,
        isConnectorMatch: preferredConnectorType == null ||
            preferredConnectorType.isEmpty ||
            s.chargerTypes.any(
              (t) =>
                  t.toLowerCase() == preferredConnectorType.toLowerCase(),
            ),
      );
    }).toList();

    // Sort by distance ascending; return the nearest.
    scored.sort(
      (a, b) => a.distanceFromRouteMidpointKm
          .compareTo(b.distanceFromRouteMidpointKm),
    );

    return scored.first;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────

  LatLng _midpoint(LatLng a, LatLng b) {
    return LatLng((a.latitude + b.latitude) / 2.0,
        (a.longitude + b.longitude) / 2.0);
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180.0;
}
