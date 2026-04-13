import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_empty_state.dart';
import 'plan_trip_screen.dart';
import 'saved_trip_details_screen.dart';
import 'trip_history_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPlanTrip() {
    final provider = context.read<TripProvider>();
    provider.resetPlanner();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlanTripScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trip Planner'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Saved Trips'),
                Tab(text: 'Trip History'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.withValues(alpha: 0.08),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    provider.isLoading && provider.savedTrips.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : provider.savedTrips.isEmpty
                            ? const TripEmptyState(
                                title: 'No saved trips yet',
                                subtitle: 'Plan a new trip and save it to see it here.',
                                icon: Icons.route,
                              )
                            : RefreshIndicator(
                                onRefresh: provider.loadSavedTrips,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                                  itemCount: provider.savedTrips.length,
                                  itemBuilder: (context, index) {
                                    final trip = provider.savedTrips[index];
                                    return TripCard(
                                      trip: trip,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SavedTripDetailsScreen(trip: trip),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                    const TripHistoryScreen(),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openPlanTrip,
            icon: const Icon(Icons.add),
            label: const Text('Plan New Trip'),
          ),
        );
      },
    );
  }
}