import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../widgets/account_widgets.dart';
import '../widgets/shared_widgets.dart';

/// Displays charging session history with summary stats at the top.
class ChargingActivityScreen extends StatefulWidget {
  const ChargingActivityScreen({super.key});

  @override
  State<ChargingActivityScreen> createState() => _ChargingActivityScreenState();
}

class _ChargingActivityScreenState extends State<ChargingActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadChargingActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final sessions = provider.chargingActivities;
    final cs = Theme.of(context).colorScheme;

    // Aggregate summary stats
    final totalSessions = sessions.length;
    final totalAmount = sessions.fold<double>(0, (s, a) => s + a.amountPaid);
    final totalEnergy =
        sessions.fold<double>(0, (s, a) => s + a.energyDeliveredKWh);

    return Scaffold(
      appBar: AppBar(title: const Text('Charging Activity')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AccountProvider>().loadChargingActivities(),
              child: CustomScrollView(
                slivers: [
                  // ── Summary cards ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        children: [
                          _SummaryCard(
                            icon: Icons.bolt_rounded,
                            label: 'Sessions',
                            value: '$totalSessions',
                            color: cs.primary,
                          ),
                          const SizedBox(width: 10),
                          _SummaryCard(
                            icon: Icons.payments_outlined,
                            label: 'Total Spent',
                            value:
                                'LKR ${totalAmount.toStringAsFixed(0)}',
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          _SummaryCard(
                            icon: Icons.battery_charging_full_rounded,
                            label: 'Energy',
                            value:
                                '${totalEnergy.toStringAsFixed(1)} kWh',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Section title ──
                  const SliverToBoxAdapter(
                    child: SectionTitle(title: 'Recent Sessions'),
                  ),

                  // ── Session list or empty state ──
                  sessions.isEmpty
                      ? const SliverFillRemaining(
                          child: AccountEmptyState(
                            icon: Icons.ev_station_outlined,
                            title: 'No Sessions Yet',
                            subtitle:
                                'Your charging history will appear here after your first session.',
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) =>
                                ChargingActivityCard(session: sessions[i]),
                            childCount: sessions.length,
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }
}

/// Compact summary stat card used inside ChargingActivityScreen.
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
