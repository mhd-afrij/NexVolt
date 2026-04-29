import 'package:flutter/material.dart';

/// A selectable chip for choosing a charger type (CCS, CHAdeMO, Type2, etc.).
class ChargerTypeChip extends StatelessWidget {
  final String type;
  final bool isSelected;
  final bool isCompatible; // true if matches vehicle connector
  final VoidCallback? onTap;

  const ChargerTypeChip({
    super.key,
    required this.type,
    required this.isSelected,
    this.isCompatible = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconFor(type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (!isCompatible) ...[
              const SizedBox(width: 4),
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: theme.colorScheme.error),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toUpperCase()) {
      case 'CCS':
        return Icons.electrical_services;
      case 'CHADEMO':
        return Icons.bolt;
      case 'TYPE2':
        return Icons.power;
      default:
        return Icons.electric_bolt;
    }
  }
}
