import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  String _languageCode = 'en';
  String? _pendingPhone;

  bool get isSignedIn => _isSignedIn;
  String get languageCode => _languageCode;
  String? get pendingPhone => _pendingPhone;

  void setSignedIn(bool value) {
    _isSignedIn = value;
    notifyListeners();
  }

  void setLanguage(String code) {
    _languageCode = code;
    notifyListeners();
  }

  void setPendingPhone(String value) {
    _pendingPhone = value;
    notifyListeners();
  }
}
