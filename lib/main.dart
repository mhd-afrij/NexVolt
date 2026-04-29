import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/account_screen.dart';

import 'app.dart';
import 'core/services/firestore_service.dart';
import 'core/services/firestore_sample_importer.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const _BootstrapApp());
}

class _BootstrapState {
  const _BootstrapState({required this.repository, this.startupWarning});

  final AppRepository repository;
  final String? startupWarning;
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  static const Duration _firebaseInitTimeout = Duration(seconds: 4);
  static const Duration _remoteSeedTimeout = Duration(seconds: 3);
  static const Duration _sampleImportTimeout = Duration(seconds: 3);

  static const bool _enableWebMaps = bool.fromEnvironment(
    'ENABLE_WEB_MAPS',
    defaultValue: true,
  );
  static const bool _importSampleFirestore = bool.fromEnvironment(
    'IMPORT_SAMPLE_FIRESTORE',
    defaultValue: false,
  );

  late final Future<_BootstrapState> _startupFuture = _prepareStartup();

  Future<_BootstrapState> _prepareStartup() async {
    String? startupWarning;
    var firebaseReady = true;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(_firebaseInitTimeout);
    } catch (_) {
      firebaseReady = false;
      startupWarning =
          'Firebase init failed. Firestore disabled, running in local mode.';
    }

    if (firebaseReady) {
      if (_importSampleFirestore) {
        unawaited(
          FirestoreSampleImporter.importSampleData()
              .timeout(_sampleImportTimeout)
              .catchError((_) {}),
        );
      }

      final repository = AppRepository(useRemoteDb: true);
      try {
        await repository.seedDefaults().timeout(_remoteSeedTimeout);
      } catch (_) {
        startupWarning ??=
            'Firebase is slow or unavailable. App loaded with limited cloud sync.';
      }

      return _BootstrapState(
        repository: repository,
        startupWarning: startupWarning,
      );
    }

    final fallbackRepository = AppRepository(useRemoteDb: false);
    await fallbackRepository.seedDefaults();

    return _BootstrapState(
      repository: fallbackRepository,
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

        final state = snapshot.data!;
        return NexVoltApp(
          repository: state.repository,
          startupWarning: state.startupWarning,
          enableMaps: !kIsWeb || _enableWebMaps,
        );
      },
    );
  }
}
