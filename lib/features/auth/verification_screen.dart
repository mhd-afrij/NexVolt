import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();

  String selectedCode = "+94";
  bool isValid = false;
  bool isLoading = false;

  late AnimationController _controller;

  final List<Map<String, String>> countries = [
    {"name": "Sri Lanka", "code": "+94"},
    {"name": "India", "code": "+91"},
    {"name": "USA", "code": "+1"},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void validateNumber(String value) {
    if (value.length == 9 && RegExp(r'^[0-9]+$').hasMatch(value)) {
      setState(() => isValid = true);
    } else {
      setState(() => isValid = false);
    }
  }

  Future<void> sendOTP() async {
    setState(() => isLoading = true);

    String number = _phoneController.text.trim();

    if (number.startsWith("0")) {
      number = number.substring(1);
    }

    String phoneNumber = selectedCode + number;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Verification Failed")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 🔥 Animated Button
  Widget animatedButton(
    String text,
    Color startColor,
    Color endColor,
    VoidCallback? onTap,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(startColor, endColor, _controller.value);
        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: color,
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF50C878);
    const electricBlue = Color(0xFF0077FF);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [emeraldGreen, electricBlue],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // 🔙 Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            // Title
            const Text(
              "Your Number",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "We will send you a verification code",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 White Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // Country Code
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCode,
                              items: countries.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country['code'],
                                  child: Text(country['code']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedCode = value!);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Phone Field
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            onChanged: validateNumber,
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // 🔥 Animated Button
                    SizedBox(
                      width: double.infinity,
                      child: animatedButton(
                        "Next",
                        emeraldGreen,
                        electricBlue,
                        isValid && !isLoading ? sendOTP : null,
                      ),
                    ),

                    const SizedBox(height: 20),
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
