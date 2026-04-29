import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'charging_active_screen.dart';
import 'payment_qr_screen.dart';


class QrScannerScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingDetails;

  const QrScannerScreen({super.key, this.bookingDetails});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false; // prevent double-fire

  // ── Default booking data (shown when no booking is passed in) ──────────
  static const Map<String, dynamic> _defaultBooking = {
    'bookingId': '#845672',
    'dateTime': '12-March-2026 10:00 AM',
    'chargerType': 'Type 02',
    'duration': '45 Minutes',
    'totalAmountPaid': 'Rs 750.00',
    'stationName': 'Preranoa Motors',
    'chargerId': '526658',
  };

  Map<String, dynamic> get _booking =>
      widget.bookingDetails ?? _defaultBooking;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _scanned = true;
    _route(raw);
  }

  void _route(String raw) {
    if (raw.startsWith('PAY:')) {
      _goPayment();
    } else if (raw.startsWith('STATION:')) {
      _goCharging();
    } else {
      // Unknown QR — show snackbar and allow re-scan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown QR code. Please scan a Nexvolt QR.')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _scanned = false);
      });
    }
  }

  void _goPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentQrScreen(booking: _booking),
      ),
    ).then((_) => setState(() => _scanned = false));
  }

  void _goCharging() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChargingActiveScreen(booking: _booking),
      ),
    ).then((_) => setState(() => _scanned = false));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('QR Scanner'),
        actions: [
          // Torch toggle
          IconButton(
            icon: const Icon(Icons.flashlight_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scanner viewport ─────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _handleBarcode,
                ),
                // Scan frame overlay
                _ScanFrame(),
                // Instruction text
                Positioned(
                  top: 32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Scan the QR code of the charger to start charging',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Booking details card + action button ─────────────
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Booking summary ──
                    Text(
                      'Your slot Booking details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking id ${_booking['bookingId']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _BookingRow('Date & Time',    _booking['dateTime']),
                    _BookingRow('Charger Type',   _booking['chargerType']),
                    _BookingRow('Duration',        _booking['duration']),
                    _BookingRow('Total amount Paid', _booking['totalAmountPaid']),
                    const Divider(height: 24),
                    Text(
                      'Please plugin charger to Start charging',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // ── Primary CTA — Start Charging (demo) ──
                    FilledButton(
                      onPressed: _goCharging,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Starting Charging',
                          style: TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(height: 10),

                    // ── Secondary — Payment QR (demo) ──
                    OutlinedButton(
                      onPressed: _goPayment,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Scan Payment QR',
                          style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Booking detail row ────────────────────────────────────────────────────
class _BookingRow extends StatelessWidget {
  final String label;
  final String value;
  const _BookingRow(this.label, this.value);

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
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Scan frame overlay widget ─────────────────────────────────────────────
class _ScanFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 220),
      painter: _FramePainter(),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 28.0; // corner length
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawLine(Offset(0, corner), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(corner, 0), paint);
    // Top-right
    canvas.drawLine(Offset(w - corner, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, corner), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, h - corner), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(corner, h), paint);
    // Bottom-right
    canvas.drawLine(Offset(w - corner, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - corner), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
