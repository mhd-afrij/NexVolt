import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = const [
      'Mar 19, 18:30 - EV Park Central - Completed',
      'Mar 12, 09:15 - GreenCharge Hub A - Completed',
      'Mar 01, 20:00 - Highway SuperPort - Cancelled',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Booking History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(bookings[index]),
              trailing: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.stationList),
                child: const Text('Rebook'),
              ),
            ),
          );
        },
      ),
    );
  }
}
