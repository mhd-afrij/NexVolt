import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_method_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedTab = 3; // Payment tab selected
  int _bottomNavIndex = 4;
  double _walletBalance = 39.43;
  double _autoReloadAmount = 20;
  final double _autoReloadThreshold = 5;
  int _selectedPaymentMethod = 0;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'static_1',
      type: 'Mastercard',
      lastDigits: '8295',
      isSelected: true,
      icon: Icons.credit_card,
      color: Colors.red,
      cvv: '123',
    ),
    PaymentMethod(
      id: 'static_2',
      type: 'Visa',
      lastDigits: '9425',
      isSelected: false,
      icon: Icons.credit_card,
      color: Colors.blue,
      cvv: '456',
    ),
  ];

  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _autoReloadController = TextEditingController();

  StreamSubscription? _paymentSubscription;
  StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();
    _balanceController.text = _walletBalance.toString();
    _autoReloadController.text = _autoReloadAmount.toString();
    _startListeners();
  }

  void _startListeners() {
    _paymentSubscription?.cancel();
    _userSubscription?.cancel();

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc('user_001')
        .snapshots()
        .listen((userDoc) {
      if (userDoc.exists && mounted) {
        setState(() {
          _walletBalance = (userDoc.data()?['walletBalance'] ?? 0).toDouble();
          _autoReloadAmount =
              (userDoc.data()?['autoReloadAmount'] ?? 20).toDouble();
        });
      }
    });

    _paymentSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc('user_001')
        .collection('paymentMethods')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _paymentMethods.clear();
          for (var doc in snapshot.docs) {
            _paymentMethods.add(PaymentMethod.fromFirestore(doc));
          }
          if (_paymentMethods.isNotEmpty) {
            if (_selectedPaymentMethod == -1 ||
                _selectedPaymentMethod >= _paymentMethods.length) {
              _selectedPaymentMethod = 0;
            }
            for (int i = 0; i < _paymentMethods.length; i++) {
              _paymentMethods[i].isSelected = (i == _selectedPaymentMethod);
            }
          } else {
            _selectedPaymentMethod = -1;
          }
        });
      }
    });
  }

  Future<void> _deleteCard(String cardId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this card?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user_001')
          .collection('paymentMethods')
          .doc(cardId)
          .delete();

      _showSnackBar('Card deleted');
    } catch (e) {
      _showSnackBar('Error deleting card: $e');
    }
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    _userSubscription?.cancel();
    _balanceController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _autoReloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EkW Card
              _buildEkWCard(),
              const SizedBox(height: 24),

              // Saved Payment Methods Title
              const Text(
                'Saved Payment Methods',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Payment Methods List
              ..._buildPaymentMethodsList(),
              const SizedBox(height: 12),

              // Add Payment Method
              _buildAddPaymentButton(),
              const SizedBox(height: 24),

              // Auto Reload Info
              _buildAutoReloadInfo(),
              const SizedBox(height: 20),

              // Action Buttons
              _buildEditAutoReloadButton(),
              const SizedBox(height: 12),
              _buildAddFundsButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton('Profile', 0),
                _buildTabButton('Charging Activity', 1),
                _buildTabButton('Notifications', 2),
                _buildTabButton('Payment', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00D9B8) : Colors.grey,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 2,
                width: 24,
                color: const Color(0xFF00D9B8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEkWCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: Color(0xFF00D9B8),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'EkW',
                    style: TextStyle(
                      color: Color(0xFF00D9B8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showEditBalanceDialog,
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFF00D9B8),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Active: EkW Plus',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${_walletBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentMethodsList() {
    return List.generate(
      _paymentMethods.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            setState(() {
              for (var method in _paymentMethods) {
                method.isSelected = false;
              }
              _paymentMethods[index].isSelected = true;
              _selectedPaymentMethod = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _paymentMethods[index].isSelected
                    ? const Color(0xFF00D9B8)
                    : const Color(0xFF3A3A3A),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _paymentMethods[index].color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _paymentMethods[index].icon,
                        color: _paymentMethods[index].color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _paymentMethods[index].type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _paymentMethods[index].lastDigits,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteCard(_paymentMethods[index].id),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPaymentButton() {
    return GestureDetector(
      onTap: _showAddPaymentDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Add Payment Method',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  '+',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoReloadInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Text(
        'Auto recharge: \$${_autoReloadAmount.toStringAsFixed(0)} when balance drops below \$${_autoReloadThreshold.toStringAsFixed(0)}',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildEditAutoReloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00D9B8), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _showEditAutoReloadDialog,
        child: const Text(
          'Edit Auto-Reload',
          style: TextStyle(
            color: Color(0xFF00D9B8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddFundsButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9B8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: () {
          if (_paymentMethods.isEmpty) {
            _showSnackBar('Please add a payment method first');
            return;
          }
          _showAddFundsDialog();
        },
        child: const Text(
          'Add Funds',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.dashboard, 'Planner', 1),
          _buildNavItem(Icons.directions_car, 'Garage', 2),
          _buildNavItem(Icons.calendar_month, 'Booking', 3),
          _buildNavItem(Icons.person, 'Account', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _bottomNavIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00D9B8) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF00D9B8) : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog() {
    _balanceController.text = _walletBalance.toStringAsFixed(2);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Edit Balance',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _balanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixText: '\$ ',
            prefixStyle: const TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00D9B8)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9B8),
            ),
            onPressed: () async {
              double? newBalance = double.tryParse(_balanceController.text);

              if (newBalance != null) {
                Navigator.pop(context);
                try {
                  // Firebase එකට data යවන කොටස
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc('user_001')
                      .set({
                        'walletBalance': newBalance,
                        'lastUpdated': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));

                  // App එකේ UI එක update කරලා dialog එක වහනවා
                  if (mounted) {
                    setState(() {
                      _walletBalance = newBalance;
                    });

                    _showSnackBar('Balance updated successfully!');
                  }
                } catch (e) {
                  if (mounted) {
                    _showSnackBar('Error: $e');
                  }
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showEditAutoReloadDialog() {
    _autoReloadController.text = _autoReloadAmount.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Edit Auto-Reload Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _autoReloadController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Reload Amount',
                labelStyle: const TextStyle(color: Colors.grey),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00D9B8)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9B8),
            ),
            onPressed: () async {
              double? newAmount = double.tryParse(_autoReloadController.text);
              if (newAmount != null) {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc('user_001')
                      .update({
                    'autoReloadAmount': newAmount,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });

                  if (mounted) {
                    setState(() {
                      _autoReloadAmount = newAmount;
                    });
                    _showSnackBar('Auto-reload settings updated!');
                  }
                } catch (e) {
                  if (mounted) {
                    _showSnackBar('Error updating settings: $e');
                  }
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    _cardNumberController.clear();
    _cardHolderController.clear();
    _expiryController.clear();
    _cvvController.clear();

    String detectedType = 'Card';
    IconData cardIcon = Icons.credit_card;
    Color cardColor = Colors.grey;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: Row(
              children: [
                const Text('Add Payment Method', style: TextStyle(color: Colors.white, fontSize: 18)),
                const Spacer(),
                if (detectedType != 'Card')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      detectedType,
                      style: TextStyle(color: cardColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      String v = value.replaceAll(' ', '');
                      String newType = 'Card';
                      IconData newIcon = Icons.credit_card;
                      Color newColor = Colors.grey;

                      if (v.startsWith('4')) {
                        newType = 'Visa';
                        newIcon = Icons.credit_card;
                        newColor = Colors.blue;
                      } else if (v.startsWith(RegExp(r'^5[1-5]')) || v.startsWith(RegExp(r'^(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)'))) {
                        newType = 'Mastercard';
                        newIcon = Icons.credit_card;
                        newColor = Colors.red;
                      }

                      setDialogState(() {
                        detectedType = newType;
                        cardIcon = newIcon;
                        cardColor = newColor;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      counterText: "",
                      labelStyle: const TextStyle(color: Colors.grey),
                      hintText: '4xxx xxxx xxxx xxxx',
                       hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                      prefixIcon: Icon(cardIcon, color: cardColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3A3A3A))),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00D9B8))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cardHolderController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Card Holder Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3A3A3A))),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00D9B8))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          onChanged: (value) {
                            if (value.length == 2 && !_expiryController.text.contains('/')) {
                              _expiryController.text = '$value/';
                              _expiryController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _expiryController.text.length),
                              );
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Expiry (MM/YY)',
                            counterText: "",
                            labelStyle: const TextStyle(color: Colors.grey),
                            hintText: '12/25',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3A3A3A))),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00D9B8))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            counterText: "",
                            labelStyle: const TextStyle(color: Colors.grey),
                            hintText: '123',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3A3A3A))),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00D9B8))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D9B8)),
                onPressed: () async {
                  String cardNumber = _cardNumberController.text.replaceAll(' ', '');
                  if (cardNumber.length != 16) {
                    _showSnackBar('Invalid Card Number (must be 16 digits)');
                    return;
                  }
                  if (_expiryController.text.length < 5) {
                    _showSnackBar('Invalid Expiry Date (MM/YY)');
                    return;
                  }
                  if (_cvvController.text.length < 3) {
                    _showSnackBar('Invalid CVV (3 digits)');
                    return;
                  }

                  try {
                    String lastDigits = cardNumber.substring(cardNumber.length - 4);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc('user_001')
                        .collection('paymentMethods')
                        .add({
                      'type': detectedType,
                      'lastDigits': lastDigits,
                      'cardHolder': _cardHolderController.text,
                      'expiry': _expiryController.text,
                      'cvv': _cvvController.text,
                      'icon': cardIcon.codePoint,
                      'color': cardColor.value,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      _showSnackBar('Payment method added successfully!');
                    }
                  } catch (e) {
                    if (mounted) {
                      _showSnackBar('Error adding card: $e');
                    }
                  }
                },
                child: const Text('ADD', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddFundsDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Add Funds',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Amount to Add',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00D9B8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_paymentMethods.length, (index) {
                    final method = _paymentMethods[index];
                    return Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: Colors.grey,
                      ),
                      child: RadioListTile<int>(
                        value: index,
                        groupValue: _selectedPaymentMethod,
                        activeColor: const Color(0xFF00D9B8),
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Icon(
                              method.icon,
                              color: method.color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.type,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '**** ${method.lastDigits}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onChanged: (int? value) {
                          if (value != null) {
                            setDialogState(() {
                              _selectedPaymentMethod = value;
                            });
                            setState(() {
                              for (var m in _paymentMethods) {
                                m.isSelected = false;
                              }
                              _paymentMethods[value].isSelected = true;
                            });
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9B8),
                ),
                onPressed: () async {
                  if (amountController.text.isEmpty) {
                    _showSnackBar('Please enter an amount');
                    return;
                  }

                  double amount = double.tryParse(amountController.text) ?? 0;

                  try {
                    final userRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc('user_001');

                    await FirebaseFirestore.instance
                        .runTransaction((transaction) async {
                      final snapshot = await transaction.get(userRef);

                      double currentBalance = 0;
                      if (snapshot.exists) {
                        currentBalance = (snapshot.data()?['walletBalance'] ?? 0).toDouble();
                      }

                      double newBalance = currentBalance + amount;

                      transaction.set(
                        userRef,
                        {
                          'walletBalance': newBalance,
                          'lastUpdated': FieldValue.serverTimestamp(),
                        },
                        SetOptions(merge: true),
                      );

                      if (mounted) {
                        setState(() {
                          _walletBalance = newBalance;
                        });
                      }
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      _showSnackBar('Added \$${amount.toStringAsFixed(2)}');
                    }
                  } catch (e) {
                    if (mounted) {
                      _showSnackBar('Error updating balance: $e');
                    }
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00D9B8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
