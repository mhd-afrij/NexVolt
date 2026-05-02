import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/station_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/charger_type_chip.dart';
import '../widgets/date_selector.dart';
import '../widgets/section_title.dart';
import '../widgets/station_booking_header.dart';
import '../widgets/time_slot_chip.dart';
import 'booking_summary_screen.dart';

/// Reserve Slot Screen — lets the user select station, vehicle, charger type,
/// date, time slot, and duration before proceeding to the booking summary.
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => ReserveSlotScreen(station: preSelectedStation)));
class ReserveSlotScreen extends StatefulWidget {
  /// Optionally pre-select a station (e.g. coming from station finder).
  final StationModel? station;

  const ReserveSlotScreen({super.key, this.station});

  @override
  State<ReserveSlotScreen> createState() => _ReserveSlotScreenState();
}

class _ReserveSlotScreenState extends State<ReserveSlotScreen> {
  // ── Mock vehicles — replace with real vehicle feature data when integrated
  // In a full app, load from VehicleProvider or Firestore.
  final _mockVehicles = [
    {'id': 'v1', 'name': 'Tesla Model 3', 'connector': 'CCS'},
    {'id': 'v2', 'name': 'Nissan Leaf', 'connector': 'CHAdeMO'},
    {'id': 'v3', 'name': 'BMW i4', 'connector': 'Type2'},
  ];

  Map<String, String>? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final prov = context.read<BookingProvider>();
    await prov.loadStations();

    // Pre-select station if provided
    if (widget.station != null) {
      prov.setSelectedStation(widget.station!);
    } else if (prov.stations.isNotEmpty && prov.selectedStation == null) {
      prov.setSelectedStation(prov.stations.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve a Slot',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading && prov.selectedStation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // ── Station header ───────────────────────────────────────────
              if (prov.selectedStation != null)
                StationBookingHeader(station: prov.selectedStation!)
              else
                _buildStationPicker(context, prov),

              // ── Station picker (if multiple available) ───────────────────
              if (prov.stations.length > 1 && prov.selectedStation != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton.icon(
                    onPressed: () => _showStationPicker(context, prov),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Change Station'),
                  ),
                ),

              const SizedBox(height: 20),

              // ── Vehicle selection ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(
                    title: 'Select Vehicle',
                    subtitle: 'Choose the vehicle to charge'),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<Map<String, String>>(
                  value: _selectedVehicle,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.directions_car_outlined),
                    hintText: 'Select your vehicle',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  items: _mockVehicles
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v['name']!),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedVehicle = v);
                    prov.setSelectedVehicle(
                      vehicleId: v['id']!,
                      vehicleName: v['name']!,
                      connectorType: v['connector']!,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Charger type ─────────────────────────────────────────────
              if (prov.selectedStation != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionTitle(
                    title: 'Charger Type',
                    subtitle: _selectedVehicle != null
                        ? 'Your vehicle uses ${_selectedVehicle!['connector']}'
                        : 'Select a connector type',
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: prov.selectedStation!.chargerTypes.map((type) {
                      final compatible = _selectedVehicle == null ||
                          _selectedVehicle!['connector'] == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChargerTypeChip(
                          type: type,
                          isSelected: prov.selectedChargerType == type,
                          isCompatible: compatible,
                          onTap: () => prov.setSelectedChargerType(type),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (prov.availableChargers.isEmpty &&
                    prov.selectedChargerType != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      '⚠️ No available chargers of this type right now.',
                      style: TextStyle(
                          color: theme.colorScheme.error, fontSize: 13),
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // ── Duration selector ────────────────────────────────────────
              if (prov.selectedChargerType != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionTitle(title: 'Session Duration'),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [30, 45, 60, 90].map((min) {
                      final selected = prov.slotDuration == min;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$min min'),
                          selected: selected,
                          onSelected: (_) => prov.setSlotDuration(min),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Date selector ────────────────────────────────────────────
              if (prov.selectedChargerType != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionTitle(title: 'Select Date'),
                ),
                const SizedBox(height: 12),
                DateSelector(
                  selectedDate: prov.selectedDate,
                  onDateSelected: prov.setSelectedDate,
                ),
              ],

              const SizedBox(height: 24),

              // ── Time slots ───────────────────────────────────────────────
              if (prov.selectedDate != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionTitle(
                    title: 'Available Time Slots',
                    subtitle: prov.isLoading ? 'Loading...' : null,
                  ),
                ),
                const SizedBox(height: 12),
                if (prov.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (prov.availableSlots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No available slots for this date. Try another day.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: prov.availableSlots.length,
                      itemBuilder: (_, i) {
                        final slot = prov.availableSlots[i];
                        return TimeSlotChip(
                          slot: slot,
                          isSelected: prov.selectedSlot?.startTime ==
                              slot.startTime,
                          onTap: () => prov.setSelectedTimeSlot(slot),
                        );
                      },
                    ),
                  ),
              ],

              // ── Price preview ────────────────────────────────────────────
              if (prov.selectedSlot != null) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.price_check,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estimated Total',
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant)),
                              Text(
                                'LKR ${prov.totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),

      // ── Continue button ────────────────────────────────────────────────────
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          final canContinue = prov.selectedStation != null &&
              prov.selectedVehicleId != null &&
              prov.selectedChargerType != null &&
              prov.selectedSlot != null &&
              (prov.availableChargers.isNotEmpty);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: canContinue ? () => _goToSummary(context, prov) : null,
                style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('Continue to Summary',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _goToSummary(BuildContext context, BookingProvider prov) async {
    const uid = 'default_user_001';
    // Create a draft booking
    final booking = await prov.confirmBooking(uid);
    if (booking != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => BookingSummaryScreen(booking: booking)),
      );
    } else if (prov.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(prov.errorMessage!)));
    }
  }

  Widget _buildStationPicker(BuildContext context, BookingProvider prov) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Loading stations...',
          style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  void _showStationPicker(BuildContext context, BookingProvider prov) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text('Select Station',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...prov.stations.map((s) => ListTile(
                leading: const Icon(Icons.ev_station),
                title: Text(s.name),
                subtitle: Text(s.address),
                selected: prov.selectedStation?.stationId == s.stationId,
                onTap: () {
                  prov.setSelectedStation(s);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}
