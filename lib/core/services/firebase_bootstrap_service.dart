import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({required this.isEnabled, this.warning});

  final bool isEnabled;
  final String? warning;
}

class FirebaseBootstrapService {
  const FirebaseBootstrapService._();

  static Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return const FirebaseBootstrapResult(isEnabled: true);
    } catch (_) {
      final warning = kIsWeb
          ? 'Firebase is not configured for web. Check hosting Firebase config.'
          : 'Firebase is not configured. Add platform config files and retry.';
      return FirebaseBootstrapResult(isEnabled: false, warning: warning);
    }
  }
}
