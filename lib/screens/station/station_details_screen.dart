import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../models/station_model.dart';
import '../../routes/app_routes.dart';

class StationDetailsScreen extends StatefulWidget {
  const StationDetailsScreen({super.key, this.station, this.mainTabIndex = 0});

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

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
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
                              Image.network(
                                'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=1200&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: surface,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: textGrey,
                                      size: 36,
                                    ),
                                  );
                                },
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
    final name = Uri.encodeComponent(station.name);

    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  void _navigateToNearbyStations() {
    Navigator.pushNamed(
      context,
      AppRoutes.stationList,
      arguments: StationListArgs(mainTabIndex: widget.mainTabIndex),
    );
  }

  void _goToMainTab(int index) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
      arguments: index,
    );
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
