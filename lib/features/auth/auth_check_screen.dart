import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../vechicle/vehicle_details_add.dart';
import '../vechicle/vechicle_details_show.dart';
import 'login_page.dart';
import 'verification_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen>
    with SingleTickerProviderStateMixin {
  // ── Logo pulse animation ──────────────────────────────
  late AnimationController _logoController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Logo fade + scale in animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoController.forward();

    _checkUser();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    User? user;

    try {
      user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {
      user = FirebaseAuth.instance.currentUser;
    }

    if (!mounted) return;

    // ❌ NOT LOGGED IN → LoginPage
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      // No Firestore doc → create one for email users
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'role': 'user',
          'loginMethod': 'email',
          'createdAt': Timestamp.now(),
        });

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailsScreen(userId: user!.uid),
          ),
        );
        return;
      }

      // Check vehicle
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('vehicles')
          .limit(1)
          .get();

      if (!mounted) return;

      if (vehicleDoc.docs.isNotEmpty) {
        // ✅ Old user with vehicle → Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VechicleDetailsShow()),
        );
      } else {
        // ✅ User exists but no vehicle → add vehicle
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailsScreen(userId: user!.uid),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔥 AuthCheck error: $e');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // ✅ Same gradient as all your other screens
          gradient: LinearGradient(
            colors: [Color(0xFF50C878), Color(0xFF0077FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ YOUR APP LOGO from assets/logo.png
            // with fade + scale animation
            AnimatedBuilder(
              animation: _logoController,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      // ── Logo image ─────────────────────
                      Image.asset(
                        'assets/logo.png', // ✅ your logo
                        height: 110,
                        width: 110,
                        // If logo has no background, keep it transparent
                        // If it looks wrong, wrap in a white circle:
                        // see the commented widget below
                      ),

                      // ── OPTIONAL: white circle background ──
                      // Uncomment this and comment out the Image.asset
                      // above if you want a white circle behind the logo:
                      //
                      // Container(
                      //   width: 120,
                      //   height: 120,
                      //   decoration: const BoxDecoration(
                      //     color: Colors.white,
                      //     shape: BoxShape.circle,
                      //   ),
                      //   padding: const EdgeInsets.all(16),
                      //   child: Image.asset('assets/logo.png'),
                      // ),
                      const SizedBox(height: 20),

                      // ── App name ───────────────────────
                      const Text(
                        'NexVolt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'EV Charging · Booking · Navigation',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // ── Loading spinner ─────────────────────────
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),

            const SizedBox(height: 16),

            const Text(
              'Please wait...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
