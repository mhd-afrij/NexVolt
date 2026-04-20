import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vechicle_details_show.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String userId;

  const VehicleDetailsScreen({super.key, required this.userId});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  String? vehicleType, company, model, battery, connector;

  late AnimationController _controller;
  final PageController _pageController = PageController();

  final List<String> vehicleTypes = ["Two Wheel", "Three Wheel", "Four Wheel"];
  final Map<String, List<String>> companies = {
    "Two Wheel": ["Honda", "Yamaha"],
    "Three Wheel": ["Bajaj", "Piaggio"],
    "Four Wheel": ["BMW", "Tesla"],
  };
  final Map<String, List<String>> models = {
    "Honda": ["CBR-100", "CB-150"],
    "Yamaha": ["R15", "FZ"],
    "Bajaj": ["RE 205", "RE 250"],
    "Piaggio": ["Ape 50", "Ape 200"],
    "BMW": ["X3", "X5"],
    "Tesla": ["Model S", "Model X"],
  };
  final List<String> batteries = ["20 kW", "50 kW", "100 kW"];
  final List<String> connectors = ["Type 1", "Type 2", "Type 3"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void nextStep() {
    if (_currentStep < 2) {
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
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection("vehicles")
        .add({
          "vehicleType": vehicleType,
          "company": company,
          "model": model,
          "battery": battery,
          "connector": connector,
          "createdAt": DateTime.now(),
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vehicle saved successfully!")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const VechicleDetailsShow()),
      (route) => false,
    );
  }

  // 🔥 Animated Button
  Widget animatedButton(VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(
          const Color(0xFF50C878),
          const Color(0xFF0077FF),
          _controller.value,
        );

        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: color,
          ),
          child: Text(
            _currentStep < 2 ? "Next" : "Save Vehicle",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget customDropdown(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget step1() {
    return Column(
      children: [
        customDropdown("Vehicle Type", vehicleType, vehicleTypes, (val) {
          setState(() {
            vehicleType = val;
            company = null;
            model = null;
          });
        }),
        if (vehicleType != null)
          customDropdown("Company", company, companies[vehicleType!]!, (val) {
            setState(() {
              company = val;
              model = null;
            });
          }),
        if (company != null)
          customDropdown("Model", model, models[company!]!, (val) {
            setState(() => model = val);
          }),
      ],
    );
  }

  Widget step2() {
    return Column(
      children: [
        customDropdown(
          "Battery",
          battery,
          batteries,
          (val) => setState(() => battery = val),
        ),
        customDropdown(
          "Connector",
          connector,
          connectors,
          (val) => setState(() => connector = val),
        ),
      ],
    );
  }

  Widget step3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        const Text(
          "Vehicle Saved!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text("Type: $vehicleType"),
        Text("Company: $company"),
        Text("Model: $model"),
        Text("Battery: $battery"),
        Text("Connector: $connector"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF50C878);
    const electricBlue = Color(0xFF0077FF);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [emeraldGreen, electricBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Title
            const Text(
              "Vehicle Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // White Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [step1(), step2(), step3()],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Button
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
