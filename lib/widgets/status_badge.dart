import 'package:flutter/material.dart';

/// Displays a coloured pill badge for a booking or payment status.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  _BadgeConfig _configFor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return _BadgeConfig('Upcoming', const Color(0xFF1565C0), const Color(0xFFE3F2FD));
      case 'started':
      case 'charging':
        return _BadgeConfig('Charging', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case 'completed':
        return _BadgeConfig('Completed', const Color(0xFF4CAF50), const Color(0xFFF1F8E9));
      case 'cancelled':
        return _BadgeConfig('Cancelled', const Color(0xFFC62828), const Color(0xFFFFEBEE));
      case 'expired':
        return _BadgeConfig('Expired', const Color(0xFF616161), const Color(0xFFF5F5F5));
      case 'payment_pending':
        return _BadgeConfig('Pending Payment', const Color(0xFFE65100), const Color(0xFFFFF3E0));
      case 'paid':
        return _BadgeConfig('Paid', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case 'failed':
        return _BadgeConfig('Failed', const Color(0xFFC62828), const Color(0xFFFFEBEE));
      case 'refunded':
        return _BadgeConfig('Refunded', const Color(0xFF6A1B9A), const Color(0xFFF3E5F5));
      default:
        return _BadgeConfig(status, const Color(0xFF37474F), const Color(0xFFECEFF1));
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color fg;
  final Color bg;
  const _BadgeConfig(this.label, this.fg, this.bg);
}
