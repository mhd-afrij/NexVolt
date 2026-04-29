import 'package:flutter/material.dart';

import 'core/services/firestore_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class NexVoltApp extends StatelessWidget {
  const NexVoltApp({
    super.key,
    required this.repository,
    this.startupWarning,
    this.enableMaps = true,
  });

  final AppRepository repository;
  final String? startupWarning;
  final bool enableMaps;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter(
      repository: repository,
      startupWarning: startupWarning,
      enableMaps: enableMaps,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nexvolt',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
