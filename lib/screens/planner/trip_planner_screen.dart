import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_empty_state.dart';
import 'plan_trip_screen.dart';
import 'saved_trip_details_screen.dart';
import 'trip_history_screen.dart';

/// Main entry screen for the Trip Planner feature.
///
/// Shows two tabs: Saved Trips and Trip History.
/// A FAB opens the Plan New Trip screen.
class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TripProvider>();
      provider.loadSavedTrips();
      provider.loadTripHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPlanTrip() {
    context.read<TripProvider>().resetPlanner();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanTripScreen()),
    ).then((_) {
      // Refresh lists when returning from plan / result screens.
      final provider = context.read<TripProvider>();
      provider.loadSavedTrips();
      provider.loadTripHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Trip Planner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.45),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Saved Trips'),
            Tab(text: 'Trip History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SavedTripsTab(),
          TripHistoryScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPlanTrip,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text(
          'Plan New Trip',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: const Color.fromARGB(255, 68, 60, 60),
        elevation: 4,
      ),
    );
  }
}

// ── Saved Trips Tab ───────────────────────────────────────────────────────

class _SavedTripsTab extends StatelessWidget {
  const _SavedTripsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.savedTrips.isEmpty) {
          return TripEmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'No Saved Trips',
            subtitle:
                'Plan a trip and save it here to quickly access your routes later.',
            actionLabel: 'Plan a Trip',
            onAction: () {
              provider.resetPlanner();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlanTripScreen()),
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadSavedTrips,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: provider.savedTrips.length,
            itemBuilder: (context, index) {
              final trip = provider.savedTrips[index];
              return TripCard(
                trip: trip,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SavedTripDetailsScreen(trip: trip),
                  ),
                ).then((_) => provider.loadSavedTrips()),
                onDelete: () => _confirmDelete(context, provider, trip.tripId),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, TripProvider provider, String tripId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text(
            'Are you sure you want to delete this trip? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteTrip(tripId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );
  }
}
