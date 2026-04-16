import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import 'payment_screen.dart';

class ReviewBookingScreen extends StatelessWidget {
  final String stationId;
  final String stationName;
  final String stationAddress;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final DurationOption selectedDuration;
  final ChargerType selectedChargerType;

  const ReviewBookingScreen({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedDuration,
    required this.selectedChargerType,
  });

  double get _subtotal => selectedChargerType.pricePerUnit * (selectedDuration.minutes / 60);
  double get _tax => _subtotal * 0.18;
  double get _total => _subtotal + _tax;

  void _proceedToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          stationId: stationId,
          stationName: stationName,
          stationAddress: stationAddress,
          selectedDate: selectedDate,
          selectedTimeSlot: selectedTimeSlot,
          selectedDuration: selectedDuration,
          selectedChargerType: selectedChargerType,
          subtotal: _subtotal,
          tax: _tax,
          total: _total,
        ),
      ),
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
          'Review Booking',
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
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildCostBreakdownCard(),
                ],
              ),
            ),
          ),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    
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
            'Booking Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.location_on_outlined, 'Station', stationName),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.place_outlined, 'Address', stationAddress),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Date',
            dateFormat.format(selectedDate),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time_outlined,
            'Time',
            selectedTimeSlot,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.timer_outlined,
            'Duration',
            selectedDuration.label,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.electric_bolt_outlined,
            'Charger',
            '${selectedChargerType.name} (${selectedChargerType.description})',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.emeraldGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.emeraldGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdownCard() {
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
            'Cost Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildCostRow(
            'Charging (${selectedDuration.label})',
            '₹${_subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _buildCostRow(
            'CGST (9%)',
            '₹${(_tax / 2).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _buildCostRow(
            'SGST (9%)',
            '₹${(_tax / 2).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emeraldGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
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
            onPressed: () => _proceedToPayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirm & Pay',
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