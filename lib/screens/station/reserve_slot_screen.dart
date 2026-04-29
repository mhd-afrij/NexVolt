import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class ReserveSlotScreen extends StatefulWidget {
  const ReserveSlotScreen({super.key});

  @override
  State<ReserveSlotScreen> createState() => _ReserveSlotScreenState();
}

class _ReserveSlotScreenState extends State<ReserveSlotScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Reserve Slot')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('Date: $dateLabel'),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Change'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text('Time: ${_selectedTime.format(context)}'),
              trailing: TextButton(
                onPressed: _pickTime,
                child: const Text('Change'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Estimated slot fee: LKR 350\nCharging billed separately by kWh.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.booking),
            child: const Text('Confirm Reservation'),
          ),
        ],
      ),
    );
  }
}
