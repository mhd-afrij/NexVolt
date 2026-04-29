import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking_model.dart';
import '../../data/models/charger_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/date_selector.dart';
import '../widgets/section_title.dart';
import '../widgets/time_slot_chip.dart';

/// Allows the user to pick a new date/time for an existing upcoming booking.
class RescheduleBookingScreen extends StatefulWidget {
  final BookingModel booking;

  const RescheduleBookingScreen({super.key, required this.booking});

  @override
  State<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  DateTime? _selectedDate;
  BookingSlotModel? _selectedSlot;
  List<BookingSlotModel> _slots = [];
  bool _loadingSlots = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.booking;
    final timeFmt = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Booking',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // ── Current booking info ─────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Booking',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text(b.stationName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      '${DateFormat('EEE, MMM d').format(b.slotStartTime)}  •  '
                      '${timeFmt.format(b.slotStartTime)} – ${timeFmt.format(b.slotEndTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // ── New date picker ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(title: 'Select New Date'),
              ),
              const SizedBox(height: 12),
              DateSelector(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
              ),

              // ── Time slots ───────────────────────────────────────────────
              if (_selectedDate != null) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionTitle(
                    title: 'Available Slots',
                    subtitle: _loadingSlots ? 'Loading...' : null,
                  ),
                ),
                const SizedBox(height: 12),
                if (_loadingSlots)
                  const Center(child: CircularProgressIndicator())
                else if (_slots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No available slots for this date.',
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant),
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
                      itemCount: _slots.length,
                      itemBuilder: (_, i) {
                        final slot = _slots[i];
                        return TimeSlotChip(
                          slot: slot,
                          isSelected:
                              _selectedSlot?.startTime == slot.startTime,
                          onTap: () =>
                              setState(() => _selectedSlot = slot),
                        );
                      },
                    ),
                  ),
              ],

              // ── Error ────────────────────────────────────────────────────
              if (prov.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(prov.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
            ],
          );
        },
      ),

      // ── Confirm reschedule button ───────────────────────────────────────
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          final canConfirm = _selectedSlot != null && !prov.isLoading;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: canConfirm ? () => _reschedule(context, prov) : null,
                style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: prov.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Reschedule',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedSlot = null;
      _loadingSlots = true;
    });

    final prov = context.read<BookingProvider>();
    try {
      final slots = await prov.loadAvailableSlots().then((_) async {
        // Fetch directly from repo using the booking's station/charger info
        return context.read<BookingProvider>().availableSlots;
      });
      // Reload via repo directly for reschedule screen
      final repo = prov;
      // Use provider's method after setting station/type context
      final freshSlots = await _fetchSlots(date);
      setState(() {
        _slots = freshSlots;
        _loadingSlots = false;
      });
    } catch (_) {
      setState(() => _loadingSlots = false);
    }
  }

  Future<List<BookingSlotModel>> _fetchSlots(DateTime date) async {
    // Access repository through provider (or inject directly if needed)
    // Here we call directly for the reschedule case
    final prov = context.read<BookingProvider>();
    // Temporarily set context to load slots for this booking's station/charger
    prov.setSelectedStation(
      // Build a minimal StationModel from the booking data
      // In a full app, you'd fetch the full station object
      // For now we reuse what we have
      context.read<BookingProvider>().selectedStation ??
          _buildStationFromBooking(),
    );
    await prov.setSelectedChargerType(widget.booking.chargerType);
    prov.setSelectedDate(date);
    await prov.loadAvailableSlots();
    return prov.availableSlots;
  }

  // Builds a minimal StationModel from booking data for slot loading
  _buildStationFromBooking() {
    return StationModel(
      stationId: widget.booking.stationId,
      name: widget.booking.stationName,
      address: widget.booking.stationAddress,
      latitude: 0,
      longitude: 0,
      availableSlots: 0,
      chargerTypes: [widget.booking.chargerType],
      pricePerKWh: 0,
      isActive: true,
      imageUrl: '',
    );
  }

  Future<void> _reschedule(BuildContext context, BookingProvider prov) async {
    if (_selectedSlot == null) return;
    final ok = await prov.rescheduleBooking(
      booking: widget.booking,
      newSlot: _selectedSlot!,
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking rescheduled successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
