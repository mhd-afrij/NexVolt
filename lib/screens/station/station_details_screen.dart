import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/station_model.dart';
import '../../routes/app_routes.dart';

class StationDetailsScreen extends StatefulWidget {
  const StationDetailsScreen({
    super.key,
    required this.repository,
    this.station,
    this.mainTabIndex = 0,
  });

  final AppRepository repository;

  final StationModel? station;
  final int mainTabIndex;

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  static const Color bg = AppColors.backgroundTop;
  static const Color card = AppColors.cardBackground;
  static const Color surface = AppColors.cardBackgroundElevated;
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.accent;
  static const Color warning = AppColors.warning;
  static const Color textWhite = AppColors.textPrimary;
  static const Color textGrey = AppColors.textSecondary;

  static const tabs = ['Overview', 'View', 'Reserve', 'Reviews'];
  static const ports = <_PortData>[
    _PortData(type: 'CCS2', status: 'Available', price: 'LKR 68 / kWh'),
    _PortData(type: 'CHAdeMO', status: 'Busy', price: 'LKR 62 / kWh'),
    _PortData(type: 'Type 2', status: 'Available', price: 'LKR 54 / kWh'),
  ];

  int selectedTab = 0;
  bool isFavorite = false;
  bool _isAdmin = false;
  bool _checkingAdmin = true;
  StationModel? _activeStation;

  @override
  void initState() {
    super.initState();
    _activeStation = widget.station;
    _loadAdminState();
  }

  Future<void> _loadAdminState() async {
    final isAdmin = await widget.repository.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _checkingAdmin = false;
    });
  }

  Future<void> _showAvailabilityEditor() async {
    final station = _activeStation ?? widget.station;
    if (station == null) return;

    final availableController = TextEditingController(
      text: station.availableSlots?.toString() ?? '',
    );
    final totalController = TextEditingController(
      text: station.totalSlots?.toString() ?? '',
    );
    final statusController = TextEditingController(
      text: station.status ?? (station.isAvailable ? 'active' : 'inactive'),
    );
    final formKey = GlobalKey<FormState>();

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: surface,
            title: const Text('Update Availability'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: availableController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available slots',
                    ),
                    validator: (value) {
                      if (int.tryParse(value ?? '') == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total slots'),
                    validator: (value) {
                      if (int.tryParse(value ?? '') == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Status is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (shouldSave != true) {
        return;
      }

      final availableSlots = int.parse(availableController.text.trim());
      final totalSlots = int.parse(totalController.text.trim());
      if (availableSlots > totalSlots) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Available slots cannot exceed total slots.'),
            ),
          );
        }
        return;
      }

      await widget.repository.updateStationAvailability(
        stationId: station.id,
        availableSlots: availableSlots,
        totalSlots: totalSlots,
        status: statusController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _activeStation = station.copyWith(
          availableSlots: availableSlots,
          totalSlots: totalSlots,
          status: statusController.text.trim(),
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Availability updated.')));
    } finally {
      availableController.dispose();
      totalController.dispose();
      statusController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final station = _activeStation ?? widget.station;
    final stationName = station?.name ?? 'Tesla Station';
    final stationAddress = station?.address ?? 'Hanover St.24';
    final distance =
        '${(station?.distanceKm ?? 2.4).toStringAsFixed(1)} km away';

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: bg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.reserveSlot);
                      },
                      child: const Text('Reserve a Slot'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: const BorderSide(color: textWhite),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.qrScanner);
                      },
                      child: const Text('Start Charging with QR'),
                    ),
                  ),
                ],
              ),
            ),
            if (_checkingAdmin)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: LinearProgressIndicator(minHeight: 2),
              )
            else if (_isAdmin && station != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _showAvailabilityEditor,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin: Update Availability'),
                  ),
                ),
              ),
            Container(
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
                  selectedIndex: widget.mainTabIndex.clamp(0, 4),
                  onDestinationSelected: _goToMainTab,
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
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bg, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(tabs.length, (index) {
                    final active = selectedTab == index;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => selectedTab = index),
                      child: SizedBox(
                        width: 82,
                        child: Column(
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                color: active ? primary : textGrey,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              width: active ? 34 : 0,
                              height: 2,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: active
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x6622C55E),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : const [],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.cardBackgroundElevated,
                                      AppColors.backgroundBottom,
                                    ],
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.ev_station,
                                  color: textGrey,
                                  size: 48,
                                ),
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xE6020617),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Material(
                                  color: card.withValues(alpha: 0.67),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      setState(() => isFavorite = !isFavorite);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite ? warning : textWhite,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 12,
                                left: 12,
                                child: _RatingBadge(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.2),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stationName,
                              style: const TextStyle(
                                color: textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stationAddress,
                              style: const TextStyle(
                                color: textGrey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  distance,
                                  style: const TextStyle(
                                    color: secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.star,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.star,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.star,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.star,
                                    ),
                                    Icon(
                                      Icons.star_half,
                                      size: 14,
                                      color: AppColors.star,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (station != null && station.hasAvailability) ...[
                              const SizedBox(height: 10),
                              Text(
                                station.availabilityLabel,
                                style: const TextStyle(
                                  color: secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListView.builder(
                        itemCount: ports.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _PortCard(port: ports[index]);
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackgroundElevated,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x99000000),
                              blurRadius: 40,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 210,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          surface,
                                          AppColors.backgroundBottom,
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.map_outlined,
                                      color: textGrey,
                                      size: 44,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: bg,
                                    ),
                                    onPressed: _openGoogleMaps,
                                    icon: const Icon(Icons.navigation),
                                    label: const Text('Navigate'),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: textWhite,
                                      side: const BorderSide(color: textGrey),
                                    ),
                                    onPressed: _navigateToNearbyStations,
                                    icon: const Icon(Icons.ev_station),
                                    label: const Text('Nearby stations'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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

  Future<void> _openGoogleMaps() async {
    final station = widget.station;
    if (station == null) return;

    final lat = station.latitude;
    final lng = station.longitude;
    final googleMapsUri = AppConfig.googleMapsSearchUri(
      latitude: lat,
      longitude: lng,
      placeName: station.name,
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  void _navigateToNearbyStations() {
    context.push(
      AppRoutes.stationList,
      extra: StationListArgs(mainTabIndex: widget.mainTabIndex),
    );
  }

  void _goToMainTab(int index) {
    context.go(AppRoutes.home, extra: index);
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _StationDetailsScreenState.card.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        children: [
          Icon(Icons.star, size: 14, color: AppColors.star),
          SizedBox(width: 6),
          Text(
            '4.8',
            style: TextStyle(
              color: _StationDetailsScreenState.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortData {
  const _PortData({
    required this.type,
    required this.status,
    required this.price,
  });

  final String type;
  final String status;
  final String price;
}

class _PortCard extends StatefulWidget {
  const _PortCard({required this.port});

  final _PortData port;

  @override
  State<_PortCard> createState() => _PortCardState();
}

class _PortCardState extends State<_PortCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.port.status == 'Available';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) => setState(() => pressed = false),
        onTapCancel: () => setState(() => pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: pressed ? 0.985 : 1,
          child: Material(
            color: _StationDetailsScreenState.card,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _StationDetailsScreenState.surface),
                  boxShadow: [
                    BoxShadow(
                      color: _StationDetailsScreenState.primary.withValues(
                        alpha: 0.27,
                      ),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: _StationDetailsScreenState.textWhite,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.port.type,
                            style: const TextStyle(
                              color: _StationDetailsScreenState.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.port.status,
                            style: TextStyle(
                              color: isAvailable
                                  ? _StationDetailsScreenState.primary
                                  : _StationDetailsScreenState.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.port.price,
                      style: TextStyle(
                        color: isAvailable
                            ? _StationDetailsScreenState.primary
                            : _StationDetailsScreenState.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
