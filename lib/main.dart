import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'garage/screens/garage_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseInitialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp(initialization: firebaseInitialization)));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> initialization;

  const MyApp({super.key, required this.initialization});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexVolt Garage',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D1B2),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: const Color(0xFF0F0F0F),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Firebase initialization failed.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F0F0F),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF00D1B2)),
              ),
            );
          }
          return const GarageDashboardScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
