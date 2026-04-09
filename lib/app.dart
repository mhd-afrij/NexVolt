import 'package:flutter/material.dart';

import 'core/services/firestore_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

class NexVoltApp extends StatelessWidget {
  const NexVoltApp({
    super.key,
    required this.repository,
    required this.firebaseReady,
    this.startupWarning,
    this.enableMaps = true,
  });

  final AppRepository repository;
  final bool firebaseReady;
  final String? startupWarning;
  final bool enableMaps;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexvolt',
      theme: AppTheme.light,
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
        settings,
        repository: repository,
        startupWarning: startupWarning,
        enableMaps: enableMaps,
      ),
      initialRoute: AppRoutes.home,
    );
  }
}
