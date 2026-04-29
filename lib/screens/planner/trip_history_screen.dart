import 'package:flutter/material.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = const [
      'Mar 20 - Office Loop - 36 km',
      'Mar 18 - Airport Transfer - 52 km',
      'Mar 13 - Weekend Ride - 128 km',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Trip History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(trips[index]),
              subtitle: const Text('Tap for trip summary'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${trips[index]}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
