import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    required this.onLongPress,
  });

  Color _getBatteryColor(double battery) {
    if (battery > 50) return const Color(0xFF00D1B2); // Teal
    if (battery >= 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final batteryColor = _getBatteryColor(vehicle.battery);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Vehicle Image (Left)
            Hero(
              tag: 'vehicle_img_${vehicle.id}',
              child: Image.network(
                vehicle.imageUrl,
                width: 120,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 80,
                  color: Colors.white10,
                  child: const Icon(LucideIcons.car, color: Colors.white54, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Vehicle Info (Right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(LucideIcons.battery, color: batteryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${vehicle.battery.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: batteryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.mapPin, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.location,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
