import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/firebase_bootstrap_service.dart';
import 'core/services/firestore_service.dart';

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
  static const bool _enableWebMaps = bool.fromEnvironment(
    'ENABLE_WEB_MAPS',
    defaultValue: false,
  );

  late final Future<_BootstrapState> _startupFuture = _prepareStartup();

  Future<_BootstrapState> _prepareStartup() async {
    final firebase = await FirebaseBootstrapService.initialize();
    final repository = AppRepository(useRemoteDb: firebase.isEnabled);
    await repository.seedDefaults().timeout(const Duration(seconds: 8));

    final warningParts = <String>[];
    if (firebase.warning != null) {
      warningParts.add(firebase.warning!);
    }

    return _BootstrapState(
      repository: repository,
      startupWarning: warningParts.isEmpty ? null : warningParts.join(' '),
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
          final fallbackRepo = AppRepository(useRemoteDb: false);
          return NexVoltApp(
            repository: fallbackRepo,
            startupWarning: 'Startup failed. Please check Firebase setup.',
            enableMaps: !kIsWeb || _enableWebMaps,
          );
        }

        return NexVoltApp(
          repository: state.repository,
          startupWarning: state.startupWarning,
          enableMaps: !kIsWeb || _enableWebMaps,
        );
      },
    );
  }
}
