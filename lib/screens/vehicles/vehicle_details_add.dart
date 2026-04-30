import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firebase_auth_service.dart';

class VehicleDetailsAddScreen extends StatefulWidget {
  final String userId;

  const VehicleDetailsAddScreen({super.key, required this.userId});

  @override
  State<VehicleDetailsAddScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsAddScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  String? selectedVehicle, vehicleType, batteryVoltage, connectorType;

  late AnimationController _controller;
  final PageController _pageController = PageController();

  final List<Map<String, String>> vehicleSpecs = const [
    {
      'vehicle': 'Tesla Model 3',
      'type': 'Car',
      'battery_voltage': '350-400V',
      'connector': 'Type 2 / CCS',
    },
    {
      'vehicle': 'Nissan Leaf',
      'type': 'Car',
      'battery_voltage': '350V',
      'connector': 'CHAdeMO',
    },
    {
      'vehicle': 'Hyundai Kona Electric',
      'type': 'Car',
      'battery_voltage': '356V',
      'connector': 'Type 2 / CCS',
    },
    {
      'vehicle': 'MG ZS EV',
      'type': 'Car',
      'battery_voltage': '350V',
      'connector': 'Type 2 / CCS',
    },
    {
      'vehicle': 'BYD Atto 3',
      'type': 'Car',
      'battery_voltage': '400V',
      'connector': 'Type 2 / CCS',
    },
    {
      'vehicle': 'Tata Nexon EV',
      'type': 'Car',
      'battery_voltage': '300-400V',
      'connector': 'Type 2 / CCS',
    },
    {
      'vehicle': 'Ather 450X',
      'type': 'Bike',
      'battery_voltage': '51V',
      'connector': 'Proprietary',
    },
    {
      'vehicle': 'Ola S1 Pro',
      'type': 'Bike',
      'battery_voltage': '48V',
      'connector': 'Proprietary',
    },
    {
      'vehicle': 'TVS iQube',
      'type': 'Bike',
      'battery_voltage': '48V',
      'connector': 'Portable Charger',
    },
  ];

  List<String> get vehicleNames =>
      vehicleSpecs.map((spec) => spec['vehicle']!).toSet().toList()..sort();

  List<String> get vehicleTypes =>
      vehicleSpecs.map((spec) => spec['type']!).toSet().toList()..sort();

  List<String> get batteryVoltages {
    final values = vehicleSpecs
        .where((spec) => vehicleType == null || spec['type'] == vehicleType)
        .map((spec) => spec['battery_voltage']!)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  List<String> get connectorTypes {
    final values = vehicleSpecs
        .where((spec) => vehicleType == null || spec['type'] == vehicleType)
        .map((spec) => spec['connector']!)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (_currentStep == 0 && vehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle type.')),
      );
      return;
    }

    if (_currentStep == 1 &&
        (batteryVoltage == null || connectorType == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select battery voltage and connector type.'),
        ),
      );
      return;
    }

    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      saveVehicle();
    }
  }

  Future<void> saveVehicle() async {
    final activeUserId = FirebaseAuthService.currentUserId ?? widget.userId;
    final modelName = selectedVehicle ?? 'Unknown Vehicle';
    final plate = vehicleType?.trim().isNotEmpty == true ? vehicleType! : '-';
    final voltageMatch = RegExp(r'\d+').firstMatch(batteryVoltage ?? '');
    final batteryPercent = int.tryParse(voltageMatch?.group(0) ?? '') ?? 0;

    try {
      final repository = AppRepository(useRemoteDb: true);
      await repository.addVehicle(
        userId: activeUserId,
        model: modelName,
        plate: plate.isEmpty ? '-' : plate,
        batteryPercent: batteryPercent,
        vehicle: selectedVehicle,
        vehicleType: vehicleType,
        battery: batteryVoltage,
        connector: connectorType,
        batteryVoltage: batteryVoltage,
        connectorType: connectorType,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save vehicle to Firestore.')),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vehicle saved successfully!")),
    );

    context.go(AppRoutes.home);
  }

  // 🔥 Animated Button
  Widget animatedButton(VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(
          AppColors.primary,
          AppColors.secondary,
          _controller.value,
        );

        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: color,
          ),
          child: Text(
            _currentStep < 1 ? "Next" : "Save Vehicle",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget customDropdown(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool enabled = true,
    String? disabledHint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        hint: Text(
          enabled ? hint : (disabledHint ?? hint),
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget step1() {
    return Column(
      children: [
        customDropdown("Vehicle", selectedVehicle, vehicleNames, (val) {
          setState(() {
            selectedVehicle = val;
            if (val == null) {
              return;
            }

            final selectedSpec = vehicleSpecs.firstWhere(
              (spec) => spec['vehicle'] == val,
            );
            vehicleType = selectedSpec['type'];
            batteryVoltage = selectedSpec['battery_voltage'];
            connectorType = selectedSpec['connector'];
          });
        }),
        customDropdown("Vehicle Type", vehicleType, vehicleTypes, (val) {
          setState(() {
            vehicleType = val;
            selectedVehicle = null;

            if (!batteryVoltages.contains(batteryVoltage)) {
              batteryVoltage = null;
            }
            if (!connectorTypes.contains(connectorType)) {
              connectorType = null;
            }
          });
        }),
      ],
    );
  }

  Widget step2() {
    return Column(
      children: [
        customDropdown(
          "Battery Voltage",
          batteryVoltage,
          batteryVoltages,
          (val) => setState(() => batteryVoltage = val),
          enabled: vehicleType != null,
          disabledHint: 'Select vehicle type first',
        ),
        customDropdown(
          "Connector Type",
          connectorType,
          connectorTypes,
          (val) => setState(() => connectorType = val),
          enabled: vehicleType != null,
          disabledHint: 'Select vehicle type first',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              "Vehicle Details",
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [step1(), step2()],
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: animatedButton(nextStep),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
