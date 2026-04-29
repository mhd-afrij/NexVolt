import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black26),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_scanner, size: 90),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Align the station QR code inside the frame.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.chargingProgress),
              child: const Text('Simulate QR Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
