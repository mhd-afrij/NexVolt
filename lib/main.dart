import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/firestore_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const _BootstrapApp());
}

class _BootstrapState {
  const _BootstrapState({
    required this.repository,
    required this.firebaseReady,
    this.startupWarning,
  });

  final AppRepository repository;
  final bool firebaseReady;
  final String? startupWarning;
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  static const bool _enableWebMaps = bool.fromEnvironment(
    'ENABLE_WEB_MAPS',
    defaultValue: false,
  );

  late final Future<_BootstrapState> _startupFuture = _prepareStartup();

  Future<_BootstrapState> _prepareStartup() async {
    if (kIsWeb) {
      final localRepository = AppRepository(firebaseReady: false);
      await localRepository.seedDefaults();
      return _BootstrapState(
        repository: localRepository,
        firebaseReady: false,
        startupWarning: 'Running with local data on web localhost.',
      );
    }

    var firebaseReady = false;
    String? startupWarning;
    late AppRepository repository;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 8));
      firebaseReady = true;
    } catch (_) {
      startupWarning = 'Firebase init failed. Running with local data.';
    }

    repository = AppRepository(firebaseReady: firebaseReady);

    if (firebaseReady) {
      try {
        await repository.seedDefaults().timeout(const Duration(seconds: 8));
      } catch (_) {
        firebaseReady = false;
        startupWarning = 'Cloud sync unavailable. Running with local data.';
        repository = AppRepository(firebaseReady: false);
        await repository.seedDefaults();
      }
    } else {
      await repository.seedDefaults();
    }

    return _BootstrapState(
      repository: repository,
      firebaseReady: firebaseReady,
      startupWarning: startupWarning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapState>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final state = snapshot.data;
        if (state == null) {
          final fallbackRepo = AppRepository(firebaseReady: false);
          return NexVoltApp(
            repository: fallbackRepo,
            firebaseReady: false,
            startupWarning: 'Startup failed. Running with local data.',
            enableMaps: !kIsWeb || _enableWebMaps,
          );
        }

        return NexVoltApp(
          repository: state.repository,
          firebaseReady: state.firebaseReady,
          startupWarning: state.startupWarning,
          enableMaps: !kIsWeb || _enableWebMaps,
        );
      },
    );
  }
}
