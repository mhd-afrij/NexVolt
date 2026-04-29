import 'package:flutter/material.dart';

import '../../data/models/booking_model.dart';
import '../../data/models/charger_model.dart';
import '../../data/models/charging_session_model.dart';
import '../../data/models/station_model.dart';
import '../../data/repositories/booking_repository.dart';

export '../../data/models/booking_model.dart';
export '../../data/models/charger_model.dart';
export '../../data/models/charging_session_model.dart';
export '../../data/models/station_model.dart';
export '../../data/repositories/booking_repository.dart';

/// Central state manager for the Booking feature.
/// Register at app root: ChangeNotifierProvider(create: (_) => BookingProvider())
class BookingProvider extends ChangeNotifier {
  final BookingRepository _repo;

  BookingProvider({BookingRepository? repository})
      : _repo = repository ?? BookingRepository();

  // ─── Loading / error ───────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() => _setError(null);

  // ─── Stations ──────────────────────────────────────────────────────────────
  List<StationModel> _stations = [];
  StationModel? _selectedStation;

  List<StationModel> get stations => _stations;
  StationModel? get selectedStation => _selectedStation;

  Future<void> loadStations() async {
    _setLoading(true);
    _setError(null);
    try {
      _stations = await _repo.getStations();
    } catch (e) {
      _setError('Failed to load stations: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedStation(StationModel station) {
    _selectedStation = station;
    // Reset downstream selections when station changes
    _selectedChargerType = null;
    _selectedCharger = null;
    _availableSlots = [];
    _selectedSlot = null;
    notifyListeners();
  }

  // ─── Vehicle ───────────────────────────────────────────────────────────────
  String? _selectedVehicleId;
  String? _selectedVehicleName;
  String? _selectedVehicleConnectorType;

  String? get selectedVehicleId => _selectedVehicleId;
  String? get selectedVehicleName => _selectedVehicleName;
  String? get selectedVehicleConnectorType => _selectedVehicleConnectorType;

  void setSelectedVehicle({
    required String vehicleId,
    required String vehicleName,
    required String connectorType,
  }) {
    _selectedVehicleId = vehicleId;
    _selectedVehicleName = vehicleName;
    _selectedVehicleConnectorType = connectorType;
    // Reset charger if connector type changed
    if (_selectedChargerType != connectorType) {
      _selectedChargerType = null;
      _selectedCharger = null;
    }
    notifyListeners();
  }

  // ─── Date / time ───────────────────────────────────────────────────────────
  DateTime? _selectedDate;
  BookingSlotModel? _selectedSlot;

  DateTime? get selectedDate => _selectedDate;
  BookingSlotModel? get selectedSlot => _selectedSlot;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null;
    _availableSlots = [];
    notifyListeners();
    if (_selectedStation != null && _selectedChargerType != null) {
      loadAvailableSlots();
    }
  }

  void setSelectedTimeSlot(BookingSlotModel slot) {
    _selectedSlot = slot;
    calculateBookingTotal();
    notifyListeners();
  }

  // ─── Charger type / charger ────────────────────────────────────────────────
  String? _selectedChargerType;
  ChargerModel? _selectedCharger;
  List<ChargerModel> _availableChargers = [];

  String? get selectedChargerType => _selectedChargerType;
  ChargerModel? get selectedCharger => _selectedCharger;
  List<ChargerModel> get availableChargers => _availableChargers;

  Future<void> setSelectedChargerType(String type) async {
    _selectedChargerType = type;
    _selectedCharger = null;
    _selectedSlot = null;
    _availableSlots = [];
    notifyListeners();

    if (_selectedStation != null) {
      await _loadAvailableChargers();
      if (_selectedDate != null) {
        await loadAvailableSlots();
      }
    }
  }

  Future<void> _loadAvailableChargers() async {
    if (_selectedStation == null || _selectedChargerType == null) return;
    try {
      _availableChargers = await _repo.getAvailableChargers(
        stationId: _selectedStation!.stationId,
        chargerType: _selectedChargerType!,
      );
      if (_availableChargers.isNotEmpty) {
        _selectedCharger = _availableChargers.first;
      }
    } catch (e) {
      _setError('Failed to load chargers: $e');
    }
    notifyListeners();
  }

  // ─── Available slots ───────────────────────────────────────────────────────
  List<BookingSlotModel> _availableSlots = [];
  int _slotDuration = 60; // default 60 minutes

  List<BookingSlotModel> get availableSlots => _availableSlots;
  int get slotDuration => _slotDuration;

  void setSlotDuration(int minutes) {
    _slotDuration = minutes;
    _selectedSlot = null;
    if (_selectedStation != null && _selectedDate != null && _selectedChargerType != null) {
      loadAvailableSlots();
    }
    notifyListeners();
  }

  Future<void> loadAvailableSlots() async {
    if (_selectedStation == null ||
        _selectedDate == null ||
        _selectedChargerType == null) return;

    _setLoading(true);
    try {
      _availableSlots = await _repo.getAvailableSlots(
        stationId: _selectedStation!.stationId,
        date: _selectedDate!,
        chargerType: _selectedChargerType!,
        durationMinutes: _slotDuration,
      );
    } catch (e) {
      _setError('Failed to load slots: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ─── Pricing ───────────────────────────────────────────────────────────────
  double _bookingAmount = 0.0;
  double _taxAmount = 0.0;
  double _totalAmount = 0.0;

  double get bookingAmount => _bookingAmount;
  double get taxAmount => _taxAmount;
  double get totalAmount => _totalAmount;

  void calculateBookingTotal() {
    if (_selectedStation == null || _selectedSlot == null) return;
    // Estimate energy: assume average EV draws 7.2 kW
    const avgKw = 7.2;
    final hours = _selectedSlot!.durationMinutes / 60.0;
    final estimatedKWh = avgKw * hours;
    _bookingAmount = estimatedKWh * _selectedStation!.pricePerKWh;
    _taxAmount = _bookingAmount * 0.08; // 8% tax
    _totalAmount = _bookingAmount + _taxAmount;
    notifyListeners();
  }

  // ─── Bookings ──────────────────────────────────────────────────────────────
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _historyBookings = [];
  BookingModel? _currentBooking;

  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get historyBookings => _historyBookings;
  BookingModel? get currentBooking => _currentBooking;

  Future<void> loadUpcomingBookings(String userId) async {
    _setLoading(true);
    _setError(null);
    try {
      _upcomingBookings = await _repo.getUpcomingBookings(userId);
    } catch (e) {
      _setError('Failed to load upcoming bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBookingHistory(String userId) async {
    _setLoading(true);
    _setError(null);
    try {
      _historyBookings = await _repo.getBookingHistory(userId);
    } catch (e) {
      _setError('Failed to load booking history: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBookingDetails(String bookingId) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentBooking = await _repo.getBookingById(bookingId);
    } catch (e) {
      _setError('Failed to load booking: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ─── Confirm booking (pre-payment) ─────────────────────────────────────────

  /// Creates the booking document in Firestore (payment_pending state).
  Future<BookingModel?> confirmBooking(String userId) async {
    if (_selectedStation == null ||
        _selectedVehicleId == null ||
        _selectedCharger == null ||
        _selectedSlot == null ||
        _selectedDate == null) {
      _setError('Please complete all booking details.');
      return null;
    }

    _setLoading(true);
    _setError(null);
    try {
      final booking = await _repo.createBooking(
        userId: userId,
        station: _selectedStation!,
        vehicleId: _selectedVehicleId!,
        vehicleName: _selectedVehicleName ?? 'My Vehicle',
        charger: _selectedCharger!,
        bookingDate: _selectedDate!,
        slotStart: _selectedSlot!.startTime,
        slotEnd: _selectedSlot!.endTime,
        durationMinutes: _selectedSlot!.durationMinutes,
        amount: _bookingAmount,
        tax: _taxAmount,
        totalAmount: _totalAmount,
      );
      _currentBooking = booking;
      return booking;
    } catch (e) {
      _setError('Failed to create booking: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Process payment ───────────────────────────────────────────────────────

  Future<BookingModel?> processPayment({
    required BookingModel booking,
    required String paymentMethod,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final confirmed = await _repo.processPaymentAndConfirmBooking(
        booking: booking,
        paymentMethod: paymentMethod,
      );
      _currentBooking = confirmed;
      // Refresh both lists immediately
      await Future.wait([
        loadUpcomingBookings(booking.userId),
        loadBookingHistory(booking.userId),
      ]);
      return confirmed;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Cancel ────────────────────────────────────────────────────────────────

  Future<bool> cancelBooking(BookingModel booking) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repo.cancelBooking(booking);
      // Remove from upcoming list
      _upcomingBookings.removeWhere((b) => b.bookingId == booking.bookingId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Reschedule ────────────────────────────────────────────────────────────

  Future<bool> rescheduleBooking({
    required BookingModel booking,
    required BookingSlotModel newSlot,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _repo.rescheduleBooking(
        booking: booking,
        newStart: newSlot.startTime,
        newEnd: newSlot.endTime,
        newDuration: newSlot.durationMinutes,
      );
      _currentBooking = updated;
      // Update in upcoming list
      final idx = _upcomingBookings.indexWhere(
          (b) => b.bookingId == booking.bookingId);
      if (idx >= 0) _upcomingBookings[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Charging ──────────────────────────────────────────────────────────────
  ChargingSessionModel? _currentChargingSession;
  ChargingSessionModel? get currentChargingSession => _currentChargingSession;

  Future<ChargingSessionModel?> startCharging(BookingModel booking) async {
    _setLoading(true);
    _setError(null);
    try {
      final session = await _repo.startChargingFromBooking(booking);
      _currentChargingSession = session;
      _currentBooking = booking.copyWith(
          bookingStatus: BookingStatus.started);
      notifyListeners();
      return session;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateChargingProgress({
    required int percentage,
    required double kWh,
    required int minutes,
  }) async {
    if (_currentChargingSession == null) return;
    try {
      await _repo.updateChargingProgress(
        sessionId: _currentChargingSession!.sessionId,
        currentPercentage: percentage,
        energyDeliveredKWh: kWh,
        durationMinutes: minutes,
      );
      _currentChargingSession = _currentChargingSession!.copyWith(
        currentPercentage: percentage,
        energyDeliveredKWh: kWh,
        durationMinutes: minutes,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to update progress: $e');
    }
  }

  Future<bool> completeCharging() async {
    if (_currentChargingSession == null || _currentBooking == null) {
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      await _repo.completeChargingSession(
        sessionId: _currentChargingSession!.sessionId,
        booking: _currentBooking!,
      );
      _currentChargingSession = _currentChargingSession!
          .copyWith(status: ChargingSessionStatus.completed);
      _currentBooking =
          _currentBooking!.copyWith(bookingStatus: BookingStatus.completed);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to complete session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Loads an existing charging session from Firestore for a booking.
  Future<void> loadChargingSession(String bookingId) async {
    try {
      _currentChargingSession =
          await _repo.getChargingSessionByBookingId(bookingId);
      notifyListeners();
    } catch (_) {}
  }

  // ─── Reset flow ─────────────────────────────────────────────────────────────

  /// Clears all booking wizard state. Call this when returning to home.
  void resetBookingFlow() {
    _selectedStation = null;
    _selectedVehicleId = null;
    _selectedVehicleName = null;
    _selectedVehicleConnectorType = null;
    _selectedDate = null;
    _selectedSlot = null;
    _selectedChargerType = null;
    _selectedCharger = null;
    _availableSlots = [];
    _availableChargers = [];
    _bookingAmount = 0;
    _taxAmount = 0;
    _totalAmount = 0;
    _currentBooking = null;
    _currentChargingSession = null;
    _errorMessage = null;
    _slotDuration = 60;
    notifyListeners();
  }
}
