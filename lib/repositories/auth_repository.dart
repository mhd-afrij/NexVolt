import '../core/services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._service);

  final AuthService _service;

  Future<bool> isSignedIn() => _service.isSignedIn();
}
