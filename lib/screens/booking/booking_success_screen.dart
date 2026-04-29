import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String stationName;
  final String stationAddress;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final DurationOption selectedDuration;
  final ChargerType selectedChargerType;
  final double total;
  final String paymentMethod;

  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
    required this.stationName,
    required this.stationAddress,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedDuration,
    required this.selectedChargerType,
    required this.total,
    required this.paymentMethod,
  });

  Future<void> _openNavigation() async {
    final address = Uri.encodeComponent(stationAddress);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSuccessIcon(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 40),
                    _buildBookingDetails(),
                  ],
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.emeraldGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.check,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Payment Successful!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Your charging session has been booked',
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBookingDetails() {
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
        children: [
          _buildDetailRow('Booking ID', '#$bookingId'),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _buildDetailRow('Station', stationName),
          const SizedBox(height: 12),
          _buildDetailRow('Date', dateFormat.format(selectedDate)),
          const SizedBox(height: 12),
          _buildDetailRow('Time', selectedTimeSlot),
          const SizedBox(height: 12),
          _buildDetailRow('Duration', selectedDuration.label),
          const SizedBox(height: 12),
          _buildDetailRow('Charger', selectedChargerType.name),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _buildDetailRow('Amount Paid', '₹${total.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildDetailRow('Payment Method', paymentMethod),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _openNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.navigation, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Navigate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (ctx) => SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(ctx).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
