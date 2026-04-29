import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_check_screen.dart';
import '../auth/welcome_screen.dart';
import '../auth/language_screen.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../auth/verification_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/booking/booking_history_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_success_screen.dart';
import '../screens/booking/payment_screen.dart';
import '../screens/charging/charging_complete_screen.dart';
import '../screens/charging/charging_progress_screen.dart';
import '../screens/charging/qr_scanner_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/planner/plan_trip_screen.dart';
import '../screens/planner/trip_history_screen.dart';
import '../screens/planner/trip_planner_screen.dart';
import '../screens/station/reserve_slot_screen.dart';
import '../screens/station/station_details_screen.dart';
import '../screens/station/station_list_screen.dart';
import '../core/services/firestore_service.dart';

class StationListArgs {
  const StationListArgs({this.mainTabIndex = 0});
  final int mainTabIndex;
}

class StationDetailsArgs {
  const StationDetailsArgs({this.mainTabIndex = 0});
  final int mainTabIndex;
}

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter createRouter({
    required AppRepository repository,
    String? startupWarning,
    bool enableMaps = true,
  }) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/auth-check',
          name: 'authCheck',
          builder: (context, state) => const AuthCheckScreen(),
        ),
        GoRoute(
          path: '/language',
          name: 'language',
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/otp',
          name: 'otp',
          builder: (context, state) => const VerificationScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => HomeScreen(
            repository: repository,
            startupWarning: startupWarning,
            enableMaps: enableMaps,
          ),
        ),
        GoRoute(
          path: '/stations',
          name: 'stationList',
          builder: (context, state) {
            final tabIndex =
                int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return StationListScreen(
              repository: repository,
              mainTabIndex: tabIndex,
            );
          },
        ),
        GoRoute(
          path: '/stations/:id',
          name: 'stationDetails',
          builder: (context, state) {
            final tabIndex =
                int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return StationDetailsScreen(
              repository: repository,
              station: null,
              mainTabIndex: tabIndex,
            );
          },
        ),
        GoRoute(
          path: '/reserve-slot',
          name: 'reserveSlot',
          builder: (context, state) => const ReserveSlotScreen(),
        ),
        GoRoute(
          path: '/booking',
          name: 'booking',
          builder: (context, state) => const BookingScreen(),
        ),
        GoRoute(
          path: '/bookings',
          name: 'bookingHistory',
          builder: (context, state) => const BookingHistoryScreen(),
        ),
        GoRoute(
          path: '/payment',
          name: 'payment',
          builder: (context, state) => const PaymentScreen(),
        ),
        GoRoute(
          path: '/booking-success',
          name: 'bookingSuccess',
          builder: (context, state) => const BookingSuccessScreen(),
        ),
        GoRoute(
          path: '/planner',
          name: 'planner',
          builder: (context, state) => const TripPlannerScreen(),
        ),
        GoRoute(
          path: '/plan-trip',
          name: 'planTrip',
          builder: (context, state) => const PlanTripScreen(),
        ),
        GoRoute(
          path: '/trip-history',
          name: 'tripHistory',
          builder: (context, state) => const TripHistoryScreen(),
        ),
        GoRoute(
          path: '/scan',
          name: 'qrScanner',
          builder: (context, state) => const QrScannerScreen(),
        ),
        GoRoute(
          path: '/charging',
          name: 'chargingProgress',
          builder: (context, state) => const ChargingProgressScreen(),
        ),
        GoRoute(
          path: '/charging-complete',
          name: 'chargingComplete',
          builder: (context, state) => const ChargingCompleteScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '404',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
