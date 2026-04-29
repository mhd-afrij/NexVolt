import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
 
import '../models/vehicle_model.dart';
import '../providers/trip_provider.dart';
import 'trip_result_screen.dart';
import '../../constants/app_colors.dart';
 
class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});
 
  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}
 
class _PlanTripScreenState extends State<PlanTripScreen>
    with SingleTickerProviderStateMixin {
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
 
  late final AnimationController _locatePulseController;
  late final Animation<double> _locatePulseAnim;
 
  double _filterRadiusKm = 35.0;
  static const List<double> _radiusOptions = [5, 10, 25, 50];
  bool _locating = false;
 
  static const LatLng _defaultCenter = LatLng(7.8731, 80.7718);
  static const double _defaultZoom = 8.0;
 
  @override
  void initState() {
    super.initState();
    _locatePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _locatePulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _locatePulseController, curve: Curves.easeInOut),
    );
 
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<TripProvider>();
      await provider.loadVehicles();
      await _locateMe(silent: true);
    });
  }
 
  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    _sheetController.dispose();
    _locatePulseController.dispose();
    super.dispose();
  }
 
  Future<void> _locateMe({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);
 
    final provider = context.read<TripProvider>();
    await provider.detectCurrentLocation();
 
    if (!mounted) return;
    setState(() => _locating = false);
 
    if (provider.currentLocation != null) {
      _startController.text = provider.startLocationName;
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: provider.currentLocation!, zoom: 14),
        ),
      );
      // ── Fetch nearby EV chargers after location is known ────────────
      await provider.fetchNearbyChargers(
        center: provider.currentLocation!,
        radiusKm: _filterRadiusKm,
        connectorType: provider.preferredChargerType,
      );
    } else if (!silent && provider.errorMessage != null) {
      _showError(provider.errorMessage!);
    }
  }
 
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterRadiusSheet(
        currentRadius: _filterRadiusKm,
        options: _radiusOptions,
        onSelected: (r) {
          setState(() => _filterRadiusKm = r);
          Navigator.pop(context);
          // Re-filter locally with new radius — no extra network call
          context.read<TripProvider>().filterNearbyChargers(radiusKm: r);
        },
      ),
    );
  }
 
  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
 
    final provider = context.read<TripProvider>();
 
    if (provider.startLatLng == null ||
        provider.startLocationName != _startController.text.trim()) {
      final ok = await provider.setStartLocation(_startController.text.trim());
      if (!ok) {
        _showError(provider.errorMessage ?? 'Could not find start location.');
        return;
      }
    }
 
    final destOk =
        await provider.setDestination(_destinationController.text.trim());
    if (!destOk) {
      _showError(provider.errorMessage ?? 'Could not find destination.');
      return;
    }
 
    if (provider.startLatLng != null && provider.destinationLatLng != null) {
      _fitMapToBounds(provider.startLatLng!, provider.destinationLatLng!);
    }
 
    final success = await provider.calculateTrip();
    if (!mounted) return;
 
    if (success) {
      final count = provider.countChargersAlongRoute();
      if (count > 0) {
        _showChargerCountBanner(count);
        await Future.delayed(const Duration(seconds: 2));
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TripResultScreen()),
      );
    } else {
      _showError(provider.errorMessage ?? 'Calculation failed.');
    }
  }
 
  void _showChargerCountBanner(int count) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.electric_bolt_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              '$count charging station${count == 1 ? '' : 's'} along your route',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
 
  void _fitMapToBounds(LatLng a, LatLng b) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }
 
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
 
  Set<Marker> _buildMarkers(TripProvider provider) {
    final markers = <Marker>{};
 
    if (provider.currentLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: provider.currentLocation!,
        infoWindow: InfoWindow(
          title: provider.startLocationName.isNotEmpty
              ? provider.startLocationName
              : 'Start',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
 
    if (provider.destinationLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: provider.destinationLatLng!,
        infoWindow: InfoWindow(
          title: provider.destinationName.isNotEmpty
              ? provider.destinationName
              : 'Destination',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
 
    // ── EV Charger markers ─────────────────────────────────────────────────
    for (final station in provider.nearbyChargers) {
      markers.add(Marker(
        markerId: MarkerId('charger_${station.id}'),
        position: station.position,
        // Yellow = operational, Orange = unknown/offline
        icon: BitmapDescriptor.defaultMarkerWithHue(
          station.isOperational
              ? BitmapDescriptor.hueYellow
              : BitmapDescriptor.hueOrange,
        ),
        infoWindow: InfoWindow(
          title: station.title,
          snippet:
              '${station.numberOfPoints} point${station.numberOfPoints == 1 ? '' : 's'}'
              ' · ${station.connectorTypes.join(', ')}',
        ),
      ));
    }
 
    return markers;
  }
 
  Set<Polyline> _buildPolylines(TripProvider provider) {
    if (provider.polylinePoints.length < 2) return {};
        return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: provider.polylinePoints,
            color: AppColors.accent,
        width: 4,
      ),
    };
  }
 
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
 
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        final hasRoute = provider.polylinePoints.length >= 2;
        final routeChargerCount =
            hasRoute ? provider.countChargersAlongRoute() : null;
 
        return Scaffold(
          body: Stack(
            children: [
              // ── Map ───────────────────────────────────────────────────
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _defaultCenter,
                  zoom: _defaultZoom,
                ),
                onMapCreated: (c) => _mapController = c,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                markers: _buildMarkers(provider),
                polylines: _buildPolylines(provider),
                padding: const EdgeInsets.only(bottom: 260),
              ),
 
              // ── Top bar ───────────────────────────────────────────────
              Positioned(
                top: topPadding + 10,
                left: 14,
                right: 14,
                child: _TopBar(
                  onBack: () => Navigator.pop(context),
                  filterRadiusKm: _filterRadiusKm,
                  onFilterTap: _showFilterSheet,
                ),
              ),
 
              // ── Info pill (route charger count OR nearby count) ───────
              if (routeChargerCount != null)
                Positioned(
                  top: topPadding + 68,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ChargerCountPill(count: routeChargerCount),
                  ),
                )
              else if (provider.nearbyChargers.isNotEmpty)
                Positioned(
                  top: topPadding + 68,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _NearbyChargerBadge(
                      count: provider.nearbyChargers.length,
                      radiusKm: _filterRadiusKm,
                    ),
                  ),
                ),
 
              // ── Locate-me FAB ─────────────────────────────────────────
              Positioned(
                right: 16,
                bottom: 295,
                child: _locating
                          ? ScaleTransition(
                        scale: _locatePulseAnim,
                        child: _MapIconButton(
                          icon: Icons.my_location_rounded,
                              color: AppColors.accent,
                          isLoading: true,
                          onTap: null,
                        ),
                      )
                    : _MapIconButton(
                        icon: Icons.my_location_rounded,
                        color: AppColors.accent,
                        onTap: _locateMe,
                      ),
              ),
 
              // ── Bottom sheet ──────────────────────────────────────────
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.44,
                minChildSize: 0.28,
                maxChildSize: 0.92,
                snap: true,
                snapSizes: const [0.28, 0.44, 0.72, 0.92],
                builder: (context, scrollController) => _TripInputSheet(
                  scrollController: scrollController,
                  formKey: _formKey,
                  startController: _startController,
                  destinationController: _destinationController,
                  provider: provider,
                  onCalculate: _calculate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
 
// ── Info pills ────────────────────────────────────────────────────────────────
 
class _ChargerCountPill extends StatelessWidget {
  final int count;
  const _ChargerCountPill({required this.count});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: count > 0 ? AppColors.success : AppColors.warning,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            const Icon(Icons.electric_bolt_rounded,
              color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            count > 0
                ? '$count charger${count == 1 ? '' : 's'} on route'
                : 'No chargers on route',
                style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
 
class _NearbyChargerBadge extends StatelessWidget {
  final int count;
  final double radiusKm;
  const _NearbyChargerBadge({required this.count, required this.radiusKm});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 8)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.electric_bolt_rounded,
              color: AppColors.warning, size: 14),
          const SizedBox(width: 5),
          Text(
            '$count nearby station${count == 1 ? '' : 's'} within ${radiusKm.toInt()} km',
            style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
 
// ── Top bar ───────────────────────────────────────────────────────────────────
 
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final double filterRadiusKm;
  final VoidCallback onFilterTap;
 
  const _TopBar(
      {required this.onBack,
      required this.filterRadiusKm,
      required this.onFilterTap});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MapIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10)
              ],
            ),
            child: const Text(
              'Plan Trip',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _FilterButton(radiusKm: filterRadiusKm, onTap: onFilterTap),
      ],
    );
  }
}
 
class _FilterButton extends StatelessWidget {
  final double radiusKm;
  final VoidCallback onTap;
  const _FilterButton({required this.radiusKm, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
                child: Icon(Icons.tune_rounded, size: 20, color: Colors.white)),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${radiusKm.toInt()}k',
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ── Filter sheet ──────────────────────────────────────────────────────────────
 
class _FilterRadiusSheet extends StatelessWidget {
  final double currentRadius;
  final List<double> options;
  final void Function(double) onSelected;
 
  const _FilterRadiusSheet(
      {required this.currentRadius,
      required this.options,
      required this.onSelected});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.mutedIcon.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.electric_bolt_rounded,
                    color: AppColors.accent, size: 18),
                SizedBox(width: 8),
                Text(
                  'Filter Charging Stations By Distance',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
          const SizedBox(height: 8),
          ...options.map((r) {
            final isSelected = r == currentRadius;
            return GestureDetector(
              onTap: () => onSelected(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1C3A5E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1C3A5E)
                        : Colors.grey.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 18,
                      color:
                          isSelected ? Colors.white : Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Within ${r.toInt()} km',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1C1C1E)),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFF007AFF),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Active',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
 
// ── Shared map icon button ────────────────────────────────────────────────────
 
class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool isLoading;
 
  const _MapIconButton(
      {required this.icon, this.onTap, this.color, this.isLoading = false});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color ?? const Color(0xFF007AFF)),
                ),
              )
            : Icon(icon, size: 20, color: color ?? const Color(0xFF1C1C1E)),
      ),
    );
  }
}
 
// ── Bottom sheet ──────────────────────────────────────────────────────────────
 
class _TripInputSheet extends StatelessWidget {
  final ScrollController scrollController;
  final GlobalKey<FormState> formKey;
  final TextEditingController startController;
  final TextEditingController destinationController;
  final TripProvider provider;
  final VoidCallback onCalculate;
 
  const _TripInputSheet({
    required this.scrollController,
    required this.formKey,
    required this.startController,
    required this.destinationController,
    required this.provider,
    required this.onCalculate,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, -6))
        ],
      ),
      child: Form(
        key: formKey,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          children: [
            Center(
                child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.mutedIcon.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const _SheetSectionLabel(text: 'Enter Your Location'),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: startController,
              hint: 'Starting point',
              icon: Icons.trip_origin_rounded,
              dotColor: AppColors.accent,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a start location' : null,
            ),
            const SizedBox(height: 16),
            const _SheetSectionLabel(text: 'Enter Your Destination'),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: destinationController,
              hint: 'Where are you going?',
              icon: Icons.location_on_rounded,
              dotColor: AppColors.success,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a destination';
                if (v.trim().toLowerCase() ==
                    startController.text.trim().toLowerCase()) {
                  return 'Cannot be same as start';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const _SheetSectionLabel(text: 'Select Perfect Charger'),
            const SizedBox(height: 10),
            _ChargerChips(
                selected: provider.preferredChargerType,
                onSelected: provider.setPreferredChargerType),
            const SizedBox(height: 20),
            if (provider.vehicles.isNotEmpty) ...[
              const _SheetSectionLabel(text: 'Select Vehicle'),
              const SizedBox(height: 8),
              _VehicleDropdown(
                vehicles: provider.vehicles,
                selected: provider.selectedVehicle,
                onChanged: provider.setSelectedVehicle,
              ),
              if (provider.selectedVehicle != null) ...[
                const SizedBox(height: 6),
                _BatteryHint(
                    percent:
                        provider.selectedVehicle!.currentBatteryPercentage),
              ],
              const SizedBox(height: 20),
            ] else ...[
              _NoVehicleWarning(),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : onCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundTop,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.backgroundTop))
                    : const Text('Plan New Trip',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _SheetSectionLabel extends StatelessWidget {
  final String text;
  const _SheetSectionLabel({required this.text});
 
    @override
    Widget build(BuildContext context) => Text(text,
      style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}
 
class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color dotColor;
  final String? Function(String?)? validator;
 
  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.dotColor,
    this.validator,
  });
 
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textInputAction: TextInputAction.next,
        style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.55), fontSize: 14),
        prefixIcon: Icon(icon, color: dotColor, size: 18),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder.withOpacity(0.15))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: dotColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFFF3B30), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFFF3B30), width: 1.5)),
      ),
    );
  }
}
 
class _ChargerChips extends StatelessWidget {
  static const _types = ['Any', 'Type 2', 'CCS', 'CHAdeMO', 'GB/T'];
  final String? selected;
  final void Function(String?) onSelected;
  const _ChargerChips({required this.selected, required this.onSelected});
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _types.map((type) {
          final isSelected =
              (selected == null && type == 'Any') || selected == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(type == 'Any' ? null : type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cardBorder.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                child: Text(type,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.backgroundTop
                                  : AppColors.textPrimary.withOpacity(0.6))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
 
class _VehicleDropdown extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final VehicleModel? selected;
  final void Function(VehicleModel) onChanged;
 
  const _VehicleDropdown(
      {required this.vehicles,
      required this.selected,
      required this.onChanged});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected?.vehicleId,
          isExpanded: true,
          hint: const Text('Select your vehicle'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: (id) {
            if (id == null) return;
            onChanged(vehicles.firstWhere((v) => v.vehicleId == id));
          },
          items: vehicles
              .map((v) => DropdownMenuItem<String>(
                    value: v.vehicleId,
                    child: Row(children: [
                        const Icon(Icons.electric_car_rounded,
                          size: 18, color: AppColors.accent),
                      const SizedBox(width: 10),
                      Text(v.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
 
class _BatteryHint extends StatelessWidget {
  final double percent;
  const _BatteryHint({required this.percent});
 
  @override
  Widget build(BuildContext context) {
    final color = percent >= 60
        ? AppColors.success
        : percent >= 25
            ? AppColors.warning
            : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(children: [
        Icon(Icons.battery_charging_full_rounded, size: 13, color: color),
        const SizedBox(width: 4),
        Text('Battery: ${percent.toStringAsFixed(0)}%',
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
 
class _NoVehicleWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9500), size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'No vehicles found. Add one in your profile first.',
            style: TextStyle(
                color: Color(0xFFFF9500),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}
