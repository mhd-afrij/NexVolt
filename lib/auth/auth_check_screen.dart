import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/services/firebase_auth_service.dart';
import '../screens/vehicles/vehicle_details_add.dart';
import '../routes/app_routes.dart';
import 'login_page.dart';

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
    final userId = FirebaseAuthService.currentUserId;

    if (!mounted) return;

    if (userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    final hasVehicle = await FirebaseAuthService.hasVehicle();

    if (!mounted) return;

    if (hasVehicle) {
      context.go(AppRoutes.home);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleDetailsAddScreen(userId: userId),
        ),
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
              builder: (context, child) => FadeTransition(
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.bolt,
                              color: Colors.white,
                              size: 56,
                            ),
                          );
                        },
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
