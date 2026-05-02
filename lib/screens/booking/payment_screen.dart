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
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String stationId;
  final String stationName;
  final String stationAddress;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final DurationOption selectedDuration;
  final ChargerType selectedChargerType;
  final double subtotal;
  final double tax;
  final double total;

  const PaymentScreen({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedDuration,
    required this.selectedChargerType,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

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
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  final List<PaymentMethod> _paymentMethods = [
    const PaymentMethod(
      id: 'wallet',
      name: 'NexVolt Wallet',
      icon: Icons.account_balance_wallet_outlined,
      category: PaymentCategory.wallet,
    ),
    const PaymentMethod(
      id: 'saved_card',
      name: '**** **** **** 4242',
      icon: Icons.credit_card,
      category: PaymentCategory.saved,
      subtitle: 'Expires 12/26',
    ),
    const PaymentMethod(
      id: 'saved_card_2',
      name: '**** **** **** 8890',
      icon: Icons.credit_card,
      category: PaymentCategory.saved,
      subtitle: 'Expires 08/25',
    ),
    const PaymentMethod(
      id: 'upi',
      name: 'UPI',
      icon: Icons.payments_outlined,
      category: PaymentCategory.other,
    ),
    const PaymentMethod(
      id: 'netbanking',
      name: 'Net Banking',
      icon: Icons.account_balance_outlined,
      category: PaymentCategory.other,
    ),
    const PaymentMethod(
      id: 'cod',
      name: 'Cash on Delivery',
      icon: Icons.money_outlined,
      category: PaymentCategory.other,
    ),
  ];

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(
          bookingId: const Uuid().v4().substring(0, 8).toUpperCase(),
          stationName: widget.stationName,
          stationAddress: widget.stationAddress,
          selectedDate: widget.selectedDate,
          selectedTimeSlot: widget.selectedTimeSlot,
          selectedDuration: widget.selectedDuration,
          selectedChargerType: widget.selectedChargerType,
          total: widget.total,
          paymentMethod: _paymentMethods
              .firstWhere((p) => p.id == _selectedPaymentMethod)
              .name,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAmountCard(),
                  const SizedBox(height: 24),
                  _buildPaymentOptions(),
                  const SizedBox(height: 16),
                  _buildAddMoneyLink(),
                ],
              ),
            ),
          ),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Amount to Pay',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${widget.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    final wallets = _paymentMethods.where((p) => p.category == PaymentCategory.wallet).toList();
    final savedCards = _paymentMethods.where((p) => p.category == PaymentCategory.saved).toList();
    final others = _paymentMethods.where((p) => p.category == PaymentCategory.other).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...wallets.map((p) => _buildPaymentOption(p)),
          const SizedBox(height: 20),
          Divider(color: AppColors.divider),
          const SizedBox(height: 20),
          const Text(
            'Saved Methods',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...savedCards.map((p) => _buildSavedCardOption(p)),
          const SizedBox(height: 20),
          Divider(color: AppColors.divider),
          const SizedBox(height: 20),
          const Text(
            'Other Methods',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...others.map((p) => _buildPaymentOption(p)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emeraldGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.emeraldGreen : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.emeraldGreen
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.emeraldGreen
                      : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(
              method.icon,
              color: isSelected
                  ? AppColors.emeraldGreen
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.emeraldGreen
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (method.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      method.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCardOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isSelected ? AppColors.emeraldGreen.withOpacity(0.15) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.emeraldGreen : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.emeraldGreen
                    : Colors.white24,
                border: Border.all(
                  color: isSelected
                      ? AppColors.emeraldGreen
                      : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(
              method.icon,
              color: isSelected
                  ? AppColors.emeraldGreen
                  : Colors.white70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.emeraldGreen
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.textSecondary
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoneyLink() {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 18,
              color: AppColors.emeraldGreen,
            ),
            const SizedBox(width: 4),
            Text(
              'Add Money to Wallet',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.emeraldGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final PaymentCategory category;
  final String? subtitle;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.subtitle,
  });
}

enum PaymentCategory {
  wallet,
  saved,
  other,
}
