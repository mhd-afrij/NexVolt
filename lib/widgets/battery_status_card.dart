import 'package:flutter/material.dart';

/// Displays EV battery summary for a planned trip:
/// starting %, required %, remaining %, and a visual bar.
class BatteryStatusCard extends StatelessWidget {
  final double batteryAtStart; // 0–100
  final double batteryRequired; // 0–100 (can exceed 100 if range insufficient)
  final double batteryRemaining; // can be negative
  final bool needsChargingStop;

  const BatteryStatusCard({
    super.key,
    required this.batteryAtStart,
    required this.batteryRequired,
    required this.batteryRemaining,
    required this.needsChargingStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Battery Summary',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _StatusPill(needsChargingStop: needsChargingStop),
            ],
          ),
          const SizedBox(height: 16),

          // Visual battery bar
          _BatteryBar(
            batteryAtStart: batteryAtStart,
            batteryRequired: batteryRequired,
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              Expanded(
                child: _BatteryStatTile(
                  label: 'Start',
                  value: '${batteryAtStart.toStringAsFixed(0)}%',
                  color: _colorForPercent(batteryAtStart),
                ),
              ),
              Expanded(
                child: _BatteryStatTile(
                  label: 'Required',
                  value: '${batteryRequired.clamp(0, 999).toStringAsFixed(0)}%',
                  color: const Color(0xFFFF9500),
                ),
              ),
              Expanded(
                child: _BatteryStatTile(
                  label: 'Remaining',
                  value: '${batteryRemaining.toStringAsFixed(0)}%',
                  color: batteryRemaining < 15
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF34C759),
                ),
              ),
            ],
          ),

          if (needsChargingStop) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF3B30),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Battery will drop below 15% reserve. '
                      'A charging stop is recommended.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFF3B30),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _colorForPercent(double pct) {
    if (pct >= 60) return const Color(0xFF34C759);
    if (pct >= 25) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final bool needsChargingStop;
  const _StatusPill({required this.needsChargingStop});

  @override
  Widget build(BuildContext context) {
    final (label, color) = needsChargingStop
        ? ('Charge Needed', const Color(0xFFFF3B30))
        : ('Battery OK', const Color(0xFF34C759));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            needsChargingStop
                ? Icons.battery_alert_rounded
                : Icons.battery_charging_full_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  final double batteryAtStart;
  final double batteryRequired;
  const _BatteryBar({
    required this.batteryAtStart,
    required this.batteryRequired,
  });

  @override
  Widget build(BuildContext context) {
    final startFrac = (batteryAtStart / 100.0).clamp(0.0, 1.0);
    final reqFrac = (batteryRequired / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current battery level bar
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth =
                constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;

            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: barWidth,
                child: Stack(
                  children: [
                    Container(height: 14, color: Colors.grey.withOpacity(0.12)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: barWidth * startFrac,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: _batteryColor(batteryAtStart),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    if (reqFrac <= startFrac)
                      Positioned(
                        left: barWidth * reqFrac,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            Text(
              '100%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _batteryColor(double pct) {
    if (pct >= 60) return const Color(0xFF34C759);
    if (pct >= 25) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }
}

class _BatteryStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BatteryStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}
