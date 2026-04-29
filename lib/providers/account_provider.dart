import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/app_notification_model.dart';
import '../../data/models/favorite_station_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/account_repository.dart';

/// Central state manager for the Account feature.
/// Register once at app root via [ChangeNotifierProvider].
/// All screens consume this provider via [context.read] / [context.watch].
class AccountProvider extends ChangeNotifier {
  final AccountRepository _repository;
  final ImagePicker _imagePicker;
  final Uuid _uuid;

  AccountProvider({
    AccountRepository? repository,
    ImagePicker? imagePicker,
  })  : _repository = repository ?? AccountRepository(),
        _imagePicker = imagePicker ?? ImagePicker(),
        _uuid = const Uuid();

  // State

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfileModel? _userProfile;
  UserProfileModel? get userProfile => _userProfile;

  List<VehicleModel> _vehicles = [];
  List<VehicleModel> get vehicles => List.unmodifiable(_vehicles);

  List<AppNotificationModel> _notifications = [];
  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  List<FavoriteStationModel> _favoriteStations = [];
  List<FavoriteStationModel> get favoriteStations =>
      List.unmodifiable(_favoriteStations);

  /// Number of unread notifications for badge display.
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  // Internal helpers

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Bulk load — called when Account tab is opened

  /// Loads all account data in parallel for the main dashboard.
  Future<void> loadAccountData() async {
    _setLoading(true);
    _setError(null);
    try {
      await Future.wait([
        loadUserProfile(),
        loadVehicles(),
        loadNotifications(),
        loadFavorites(),
        loadChargingActivities(),
      ]);
    } catch (e) {
      _setError('Failed to load account data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // User Profile

  Future<void> loadUserProfile() async {
    try {
      _userProfile = await _repository.getUserProfile();
      notifyListeners();
    } catch (e) {
      _setError('Could not load profile: $e');
    }
  }

  /// Updates the user profile with new values.
  Future<bool> updateProfile(UserProfileModel updated) async {
    _setLoading(true);
    try {
      final withTimestamp =
          updated.copyWith(updatedAt: DateTime.now());
      await _repository.updateUserProfile(withTimestamp);
      _userProfile = withTimestamp;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Opens the image picker, uploads the selected image, and updates the profile.
  Future<void> pickAndUploadProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 512,
      );
      if (picked == null) return; // User cancelled

      _setLoading(true);
      final file = File(picked.path);
      final url = await _repository.uploadProfileImage(file);

      if (_userProfile != null) {
        final updated = _userProfile!.copyWith(profileImageUrl: url);
        await _repository.updateUserProfile(updated);
        _userProfile = updated;
        notifyListeners();
      }
    } catch (e) {
      _setError('Image upload failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Vehicles
  Future<void> loadVehicles() async {
    try {
      _vehicles = await _repository.getUserVehicles();
      notifyListeners();
    } catch (e) {
      _setError('Could not load vehicles: $e');
    }
  }

  Future<bool> addVehicle(VehicleModel vehicle) async {
    _setLoading(true);
    try {
      final withId = vehicle.copyWith(
        vehicleId: _uuid.v4(),
        userId: _repository.currentUserId,
        createdAt: DateTime.now(),
      );
      await _repository.addVehicle(withId);
      _vehicles = [..._vehicles, withId];
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add vehicle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicle) async {
    _setLoading(true);
    try {
      await _repository.updateVehicle(vehicle);
      _vehicles = _vehicles
          .map((v) => v.vehicleId == vehicle.vehicleId ? vehicle : v)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update vehicle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    _setLoading(true);
    try {
      await _repository.deleteVehicle(vehicleId);
      _vehicles = _vehicles
          .where((v) => v.vehicleId != vehicleId)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete vehicle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  // Notifications

  Future<void> loadNotifications() async {
    try {
      _notifications = await _repository.getNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Could not load notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      _notifications = _notifications.map((n) {
        return n.notificationId == notificationId
            ? n.copyWith(isRead: true)
            : n;
      }).toList();
      notifyListeners();
    } catch (e) {
      _setError('Could not mark notification: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Could not mark all notifications: $e');
    }
  }

  // Favorites

  Future<void> loadFavorites() async {
    try {
      _favoriteStations = await _repository.getFavoriteStations();
      notifyListeners();
    } catch (e) {
      _setError('Could not load favorites: $e');
    }
  }

  Future<bool> removeFavorite(String favoriteId) async {
    _setLoading(true);
    try {
      await _repository.removeFavoriteStation(favoriteId);
      _favoriteStations = _favoriteStations
          .where((f) => f.favoriteId != favoriteId)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove favourite: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Settings

  Future<void> toggleNotifications(bool enabled) async {
    if (_userProfile == null) return;
    try {
      await _repository.updateSettings({'notificationsEnabled': enabled});
      _userProfile = _userProfile!.copyWith(notificationsEnabled: enabled);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update notifications setting: $e');
    }
  }

  Future<void> toggleAutoReload(bool enabled) async {
    if (_userProfile == null) return;
    try {
      await _repository.updateSettings({'autoReloadEnabled': enabled});
      _userProfile = _userProfile!.copyWith(autoReloadEnabled: enabled);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update auto-reload setting: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_userProfile == null) return;
    try {
      await _repository.updateSettings({'language': languageCode});
      _userProfile = _userProfile!.copyWith(language: languageCode);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update language: $e');
    }
  }

  Future<void> changeThemeMode(String mode) async {
    if (_userProfile == null) return;
    try {
      await _repository.updateSettings({'themeMode': mode});
      _userProfile = _userProfile!.copyWith(themeMode: mode);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update theme: $e');
    }
  }

  // Auth

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.signOut();
      // Clear all local state after logout
      _userProfile = null;
      _vehicles = [];
      _notifications = [];
      _favoriteStations = [];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }
}
