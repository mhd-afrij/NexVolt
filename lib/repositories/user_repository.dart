import '../core/services/firestore_service.dart';

class UserRepository {
  UserRepository(this._repository);

  final AppRepository _repository;

  Stream<Map<String, dynamic>> watchProfile() => _repository.watchProfile();
}
