import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking_model.dart';
import '../../data/services/qr_service.dart';
import '../providers/booking_provider.dart';
import 'charging_progress_screen.dart';

/// QR scanner screen for booking check-in.
/// Falls back to manual verification code entry if scanner unavailable.
class QrCheckinScreen extends StatefulWidget {
  final BookingModel booking;

  const QrCheckinScreen({super.key, required this.booking});

  @override
  State<QrCheckinScreen> createState() => _QrCheckinScreenState();
}

class _QrCheckinScreenState extends State<QrCheckinScreen> {
  final _qrService = QrService();
  final MobileScannerController _scannerController = MobileScannerController();
  final _manualController = TextEditingController();

  bool _scanned = false;
  bool _showManualEntry = false;
  String? _errorMsg;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                setState(() => _showManualEntry = !_showManualEntry),
            child: Text(_showManualEntry ? 'Scan QR' : 'Enter Code',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _showManualEntry
          ? _buildManualEntry(context, theme)
          : _buildScanner(context, theme),
    );
  }

  // ── QR Scanner ─────────────────────────────────────────────────────────────

  Widget _buildScanner(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Point your camera at the QR code shown at the charging station.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        // Scanner viewfinder
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  if (_scanned) return;
                  final raw = capture.barcodes.firstOrNull?.rawValue;
                  if (raw != null) _handleScan(context, raw);
                },
              ),
              // Overlay frame
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.primary, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_errorMsg != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_errorMsg!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ── Manual entry ───────────────────────────────────────────────────────────

  Widget _buildManualEntry(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Verification Code',
              style:
                  theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Enter the 8-character code from your booking details screen.',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _manualController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 6),
            decoration: InputDecoration(
              hintText: 'XXXXXXXX',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 18),
            ),
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: 8),
            Text(_errorMsg!,
                style: TextStyle(color: theme.colorScheme.error)),
          ],
          const Spacer(),
          Consumer<BookingProvider>(
            builder: (context, prov, _) => FilledButton(
              onPressed: prov.isLoading
                  ? null
                  : () => _verifyManual(context),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: prov.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify & Check-in',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  Future<void> _handleScan(BuildContext context, String rawValue) async {
    setState(() => _scanned = true);
    await _scannerController.stop();

    final valid = _qrService.validateQr(
      scannedValue: rawValue,
      expectedBookingId: widget.booking.bookingId,
    );

    if (!valid) {
      setState(() {
        _errorMsg = 'Invalid QR code. Please scan the correct booking QR.';
        _scanned = false;
      });
      await _scannerController.start();
      return;
    }

    await _startCharging(context);
  }

  Future<void> _verifyManual(BuildContext context) async {
    final code = _manualController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMsg = 'Please enter the verification code.');
      return;
    }

    final valid = _qrService.validateManualCode(
      enteredCode: code,
      bookingId: widget.booking.bookingId,
    );

    if (!valid) {
      setState(() => _errorMsg = 'Incorrect code. Please check and try again.');
      return;
    }

    await _startCharging(context);
  }

  Future<void> _startCharging(BuildContext context) async {
    final prov = context.read<BookingProvider>();
    final session = await prov.startCharging(widget.booking);

    if (session != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChargingProgressScreen(
              booking: prov.currentBooking ?? widget.booking),
        ),
      );
    } else if (prov.errorMessage != null && context.mounted) {
      setState(() => _errorMsg = prov.errorMessage);
    }
  }
}
