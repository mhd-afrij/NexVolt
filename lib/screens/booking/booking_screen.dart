import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../widgets/booking_card.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.stationList),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Book New Slot',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const BookingCard(title: 'Tomorrow 09:00 - GreenCharge Hub A'),
                const BookingCard(title: 'Friday 18:30 - EV Park Central'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.payment),
                  icon: const Icon(Icons.payment),
                  label: const Text('Proceed to Payment'),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                BookingCard(title: 'Completed - Tesla Station - 14.2 kWh'),
                BookingCard(title: 'Completed - CityCharge One - 11.8 kWh'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
