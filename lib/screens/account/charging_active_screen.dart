import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChargingActiveScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  const ChargingActiveScreen({super.key, required this.booking});

  @override
  State<ChargingActiveScreen> createState() => _ChargingActiveScreenState();
}

class _ChargingActiveScreenState extends State<ChargingActiveScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────
  bool _isDone = false;

  // Timer / counters
  late int _remainingSeconds;   // counts down
  double _energyDelivered = 3.0;// kWh — increments
  double _batteryPercent  = 35.0;// % — starts at 35, ends at 75

  Timer? _timer;

  // Animation controller for the circular progress ring
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  // ── Default / demo values ──────────────────────────────────
  static const int _totalSeconds = 15 * 60; // 45 min booking → demo: 15 min

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds;

    // Ring animation
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ringAnim = Tween<double>(begin: 35 / 100, end: 35 / 100)
        .animate(_ringController);

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;

          // Simulate energy & battery incrementing
          final progress =
              1 - (_remainingSeconds / _totalSeconds); // 0→1
          _energyDelivered = 3.0 + progress * 4.0;    // 3→7 kWh
          _batteryPercent  = 35.0 + progress * 40.0;  // 35→75%

          // Animate ring
          _ringAnim = Tween<double>(
            begin: _ringAnim.value,
            end: _batteryPercent / 100,
          ).animate(_ringController);
          _ringController.forward(from: 0);
        } else {
          t.cancel();
          _isDone = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} Left';
  }

  void _stopCharging() {
    _timer?.cancel();
    setState(() => _isDone = true);
  }

  void _reportIssue() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ReportIssueSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isDone ? _buildDoneScreen() : _buildActiveScreen();
  }

  // ── Screen 2: Charging Active ──────────────────────────────
  Widget _buildActiveScreen() {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charge Connected'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Station info ──
              _StationInfo(
                stationName: widget.booking['stationName'] ?? 'Preranoa Motors',
                chargerId: widget.booking['chargerId'] ?? '526658',
              ),
              const SizedBox(height: 8),

              Text(
                'Your EV is charging',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),

              // ── Circular battery ring ──
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (_, __) => _BatteryRing(
                  percent: _batteryPercent,
                  animated: _ringAnim.value,
                ),
              ),
              const SizedBox(height: 32),

              // ── Stats row ──
              _StatRow(
                icon: Icons.timer_outlined,
                label: 'Time Remaining',
                value: _timeLabel,
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.bolt_rounded,
                label: 'Energy Delivered',
                value: '${_energyDelivered.toStringAsFixed(1)} units',
              ),
              const Spacer(),

              // ── Buttons ──
              FilledButton(
                onPressed: _stopCharging,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: cs.error,
                ),
                child: const Text('Stop Charging',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _reportIssue,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Report an issue',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneScreen() {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Complete'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Text(
                'Your EV is charging\nis done',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── Station info ──
              _StationInfo(
                stationName: widget.booking['stationName'] ?? 'Preranoa Motors',
                chargerId: widget.booking['chargerId'] ?? '526658',
              ),
              const SizedBox(height: 28),

              // ── Final battery ring at 75% ──
              _BatteryRing(percent: _batteryPercent, animated: _batteryPercent / 100),
              const SizedBox(height: 32),

              // ── Final stats ──
              _StatRow(
                icon: Icons.bolt_rounded,
                label: 'Energy Delivered',
                value: '${_energyDelivered.toStringAsFixed(0)} Units',
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.battery_charging_full_rounded,
                label: 'Current charge of your Ev',
                value: '${_batteryPercent.toStringAsFixed(0)}%',
              ),
              const Spacer(),

              // ── Summary card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    _SummaryRow('Duration',    widget.booking['duration'] ?? '45 Minutes'),
                    _SummaryRow('Amount Paid', widget.booking['totalAmountPaid'] ?? 'Rs 750.00'),
                    _SummaryRow('Booking ID',  widget.booking['bookingId'] ?? '#845672'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Back to Home ──
              FilledButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Home',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _reportIssue,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Report an issue',
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryRing extends StatelessWidget {
  final double percent;   // 0–100, shown as label
  final double animated;  // 0.0–1.0, drives arc

  const _BatteryRing({required this.percent, required this.animated});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _RingPainter(
          progress: animated,
          trackColor: cs.surfaceContainerHighest,
          fillColor: cs.primary,
        ),
        child: Center(
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 14;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Fill
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = fillColor
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}


class _StationInfo extends StatelessWidget {
  final String stationName;
  final String chargerId;
  const _StationInfo({required this.stationName, required this.chargerId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.ev_station_rounded,
              color: cs.onPrimaryContainer, size: 22),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stationName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text('charger ID $chargerId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    )),
          ],
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    )),
          ],
        ),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ReportIssueSheet extends StatefulWidget {
  const _ReportIssueSheet();

  @override
  State<_ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<_ReportIssueSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Report an Issue',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the issue…',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: cs.surfaceContainerLow,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Issue reported. We\'ll look into it.')),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
