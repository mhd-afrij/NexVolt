import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/payment_method_tile.dart';
import 'booking_success_screen.dart';

/// Mock payment screen. Simulates card/wallet/bank payment flows.
/// Replace [BookingProvider.processPayment] with a real gateway when ready.
class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'card';

  static const _methods = [
    {
      'id': 'card',
      'label': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, Amex',
      'icon': Icons.credit_card,
    },
    {
      'id': 'wallet',
      'label': 'Digital Wallet',
      'subtitle': 'eZ Cash, FriMi',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'bank_transfer',
      'label': 'Bank Transfer',
      'subtitle': 'Online banking',
      'icon': Icons.account_balance_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Amount card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.ev_station,
                            color: theme.colorScheme.onPrimary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.booking.stationName,
                              style: TextStyle(
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.8),
                                  fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LKR ${widget.booking.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Base: LKR ${widget.booking.amount.toStringAsFixed(2)}  •  Tax: LKR ${widget.booking.tax.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text('Choose Payment Method',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              // ── Payment method tiles ─────────────────────────────────────
              ..._methods.map((m) => PaymentMethodTile(
                    method: m['id'] as String,
                    label: m['label'] as String,
                    subtitle: m['subtitle'] as String,
                    icon: m['icon'] as IconData,
                    isSelected: _selectedMethod == m['id'],
                    onTap: () =>
                        setState(() => _selectedMethod = m['id'] as String),
                  )),

              const SizedBox(height: 20),

              // ── Mock notice ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security_outlined,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🔒 Demo mode — no real transaction will occur.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Error message ────────────────────────────────────────────
              if (prov.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(prov.errorMessage!,
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: prov.clearError,
                        color: theme.colorScheme.onErrorContainer,
                        iconSize: 18,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          );
        },
      ),

      // ── Pay button ──────────────────────────────────────────────────────────
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, prov, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed:
                  prov.isLoading ? null : () => _pay(context, prov),
              icon: prov.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.lock_outline),
              label: Text(
                  prov.isLoading
                      ? 'Processing...'
                      : 'Pay LKR ${widget.booking.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, BookingProvider prov) async {
    prov.clearError();
    final confirmed = await prov.processPayment(
      booking: widget.booking,
      paymentMethod: _selectedMethod,
    );

    if (confirmed != null && context.mounted) {
      // Replace entire booking wizard stack up to the booking screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(booking: confirmed)),
        (route) => route.isFirst,
      );
    }
  }
}
