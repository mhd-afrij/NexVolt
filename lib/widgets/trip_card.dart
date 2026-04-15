import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.route_outlined),
        title: Text(label),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
