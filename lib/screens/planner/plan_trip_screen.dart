import 'package:flutter/material.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _batteryController = TextEditingController(text: '70');
  String _result = 'No route calculated yet.';

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _batteryController.dispose();
    super.dispose();
  }

  void _calculate() {
    final battery = int.tryParse(_batteryController.text.trim()) ?? 0;
    setState(() {
      _result = battery > 50
          ? 'Estimated: 1 stop recommended on this trip.'
          : 'Estimated: 2 stops recommended for safe arrival.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Trip')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _fromController,
            decoration: const InputDecoration(labelText: 'From'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _toController,
            decoration: const InputDecoration(labelText: 'To'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _batteryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Current Battery %'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.route),
            label: const Text('Calculate Route'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(_result),
            ),
          ),
        ],
      ),
    );
  }
}
