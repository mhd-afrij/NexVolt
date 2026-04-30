import 'package:flutter/material.dart';
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
