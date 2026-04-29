import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/booking_provider.dart';
import '../../../../theme/app_colors.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_empty_state.dart';
import '../widgets/section_title.dart';
import 'booking_details_screen.dart';
import 'reserve_slot_screen.dart';

/// Main Booking hub screen — sits inside the app's bottom navigation shell.
/// Contains tabs for Upcoming and History bookings.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Default mock user ID — replace with real auth when ready
  static const String _defaultUserId = 'default_user_001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    const uid = _defaultUserId;
    final prov = context.read<BookingProvider>();
    await Future.wait([
      prov.loadUpcomingBookings(uid),
      prov.loadBookingHistory(uid),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const uid = _defaultUserId;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your EV charging reservations',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Custom Pill Tabs ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: AppColors.onPrimary,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab Content ──────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _UpcomingTab(userId: uid, onRefresh: _loadAll),
                  _HistoryTab(userId: uid, onRefresh: _loadAll),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── FAB: start a new booking ───────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewBooking(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'New Booking',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  void _startNewBooking(BuildContext context) {
    // Reset flow state before entering the wizard
    context.read<BookingProvider>().resetBookingFlow();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReserveSlotScreen()),
    );
  }
}

// ─── Upcoming tab ──────────────────────────────────────────────────────────────

class _UpcomingTab extends StatelessWidget {
  final String userId;
  final Future<void> Function() onRefresh;

  const _UpcomingTab({required this.userId, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.upcomingBookings.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              children: const [
                SizedBox(height: 80),
                BookingEmptyState(
                  title: 'No upcoming bookings',
                  subtitle:
                      'Tap "Book a Slot" to reserve a charging session at a nearby station.',
                  icon: Icons.electric_bolt_outlined,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(
                  title: 'Upcoming Bookings',
                  subtitle: '${prov.upcomingBookings.length} reservations',
                ),
              ),
              const SizedBox(height: 8),
              ...prov.upcomingBookings.map(
                (b) => BookingCard(
                  booking: b,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingDetailsScreen(bookingId: b.bookingId)),
                  ),
                  onCancel: () => _confirmCancel(context, prov, b),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(
      BuildContext context, BookingProvider prov, booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await prov.cancelBooking(booking);
      if (prov.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(prov.errorMessage!)));
      }
    }
  }
}

// ─── History tab ──────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final String userId;
  final Future<void> Function() onRefresh;

  const _HistoryTab({required this.userId, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.historyBookings.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              children: const [
                SizedBox(height: 80),
                BookingEmptyState(
                  title: 'No booking history',
                  subtitle: 'Completed and cancelled bookings will appear here.',
                  icon: Icons.history,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(
                  title: 'Booking History',
                  subtitle: '${prov.historyBookings.length} bookings',
                ),
              ),
              const SizedBox(height: 8),
              ...prov.historyBookings.map(
                (b) => BookingCard(
                  booking: b,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingDetailsScreen(bookingId: b.bookingId)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
