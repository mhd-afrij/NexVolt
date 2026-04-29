import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/app_notification_model.dart';
import '../../data/models/charging_activity_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/vehicle_model.dart';

// account_menu_tile.dart  —  Navigation row on AccountScreen

class AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;

  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? cs.primary).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? cs.primary),
      ),
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

// vehicle_card.dart  —  EV vehicle display card

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final batteryColor = vehicle.currentBatteryPercentage > 50
        ? Colors.green
        : vehicle.currentBatteryPercentage > 20
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.electric_car_rounded,
                      color: cs.onPrimaryContainer, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(vehicle.vehicleType,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  )),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    tooltip: 'Edit'),
                IconButton(
                    icon: Icon(Icons.delete_outline, color: cs.error),
                    onPressed: onDelete,
                    tooltip: 'Delete'),
              ],
            ),
            const SizedBox(height: 12),
            // Battery bar
            Row(
              children: [
                Icon(Icons.battery_charging_full_rounded,
                    size: 16, color: batteryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: vehicle.currentBatteryPercentage / 100,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(batteryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${vehicle.currentBatteryPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: batteryColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _chip(context, '${vehicle.batteryCapacityKWh} kWh',
                    Icons.bolt_rounded),
                _chip(context, vehicle.connectorType,
                    Icons.electrical_services_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.primary),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

// payment_method_card.dart  —  Masked card display

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = method.isDefault
        ? const LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF020617),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF374151),
              Color(0xFF111827),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      height: 190,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── TOP ROW ───
          Row(
            children: [
              _buildBrandLogo(method.type),
              const Spacer(),

              if (method.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),

          const Spacer(),

          // ─── CARD NUMBER ───
          const Text(
            'CARD NUMBER',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            method.maskedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 20),

          // ─── BOTTOM ROW ───
          Row(
            children: [
              Expanded(
                child: _CardInfo(
                  label: 'CARD HOLDER',
                  value: method.cardHolderName.isNotEmpty
                      ? method.cardHolderName.toUpperCase()
                      : 'NEXVOLT USER',
                ),
              ),
              _CardInfo(
                label: 'EXPIRES',
                value: method.formattedExpiry,
              ),

              const SizedBox(width: 10),

              if (!method.isDefault)
                IconButton(
                  onPressed: onSetDefault,
                  icon: const Icon(Icons.star_border_rounded,
                      color: Colors.white70),
                ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BRAND LOGO ───
  Widget _buildBrandLogo(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        );

      case 'mastercard':
        return Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );

      case 'amex':
        return const Text(
          'AMEX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        );

      default:
        return const Icon(Icons.credit_card,
            color: Colors.white, size: 28);
    }
  }
}

// ─── CARD INFO WIDGET ───
class _CardInfo extends StatelessWidget {
  final String label;
  final String value;

  const _CardInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// charging_activity_card.dart  —  Session summary row

class ChargingActivityCard extends StatelessWidget {
  final ChargingActivityModel session;

  const ChargingActivityCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = session.status == 'completed'
        ? Colors.green
        : session.status == 'cancelled'
            ? cs.error
            : cs.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.ev_station_rounded,
                  color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.stationName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy  HH:mm')
                        .format(session.startTime),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: [
                      _stat(context, '${session.energyDeliveredKWh} kWh',
                          Icons.bolt_rounded),
                      _stat(context, '${session.durationMinutes} min',
                          Icons.timer_outlined),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LKR ${session.amountPaid.toStringAsFixed(0)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 12, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 3),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

// notification_tile.dart  —  Single notification row

class NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'session':
        return Icons.ev_station_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? cs.primaryContainer.withOpacity(0.15) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForType(notification.type),
                  size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.normal,
                          )),
                  const SizedBox(height: 2),
                  Text(notification.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM  HH:mm').format(notification.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.outline,
                        ),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, left: 8),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
