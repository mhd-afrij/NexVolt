import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              title: Text('Booking Amount'),
              trailing: Text('LKR 41.50'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Card', 'Mobile Wallet', 'Cash at Station']
                .map(
                  (method) => ChoiceChip(
                    label: Text(method),
                    selected: _selectedMethod == method,
                    onSelected: (_) => setState(() => _selectedMethod = method),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.bookingSuccess),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }
}
