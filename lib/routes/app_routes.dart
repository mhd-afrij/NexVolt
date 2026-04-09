import 'package:flutter/material.dart';

import '../core/services/firestore_service.dart';
import '../screens/auth/language_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/signup_screen.dart';
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

class AppRoutes {
  AppRoutes._();

  static const language = '/language';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const home = '/home';
  static const stationList = '/station-list';
  static const stationDetails = '/station-details';
  static const reserveSlot = '/reserve-slot';
  static const booking = '/booking';
  static const bookingHistory = '/booking-history';
  static const payment = '/payment';
  static const bookingSuccess = '/booking-success';
  static const planner = '/planner';
  static const planTrip = '/plan-trip';
  static const tripHistory = '/trip-history';
  static const qrScanner = '/qr-scanner';
  static const chargingProgress = '/charging-progress';
  static const chargingComplete = '/charging-complete';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required AppRepository repository,
    required String? startupWarning,
    required bool enableMaps,
  }) {
    switch (settings.name) {
      case language:
        return MaterialPageRoute(builder: (_) => const LanguageScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            repository: repository,
            startupWarning: startupWarning,
            enableMaps: enableMaps,
          ),
        );
      case stationList:
        return MaterialPageRoute(builder: (_) => const StationListScreen());
      case stationDetails:
        return MaterialPageRoute(builder: (_) => const StationDetailsScreen());
      case reserveSlot:
        return MaterialPageRoute(builder: (_) => const ReserveSlotScreen());
      case booking:
        return MaterialPageRoute(builder: (_) => const BookingScreen());
      case bookingHistory:
        return MaterialPageRoute(builder: (_) => const BookingHistoryScreen());
      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case bookingSuccess:
        return MaterialPageRoute(builder: (_) => const BookingSuccessScreen());
      case planner:
        return MaterialPageRoute(builder: (_) => const TripPlannerScreen());
      case planTrip:
        return MaterialPageRoute(builder: (_) => const PlanTripScreen());
      case tripHistory:
        return MaterialPageRoute(builder: (_) => const TripHistoryScreen());
      case qrScanner:
        return MaterialPageRoute(builder: (_) => const QrScannerScreen());
      case chargingProgress:
        return MaterialPageRoute(
          builder: (_) => const ChargingProgressScreen(),
        );
      case chargingComplete:
        return MaterialPageRoute(
          builder: (_) => const ChargingCompleteScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            repository: repository,
            startupWarning: startupWarning,
            enableMaps: enableMaps,
          ),
        );
    }
  }
}
