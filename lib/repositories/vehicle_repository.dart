import '../core/services/firestore_service.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  VehicleRepository(this._repository);

  final AppRepository _repository;

  Stream<List<VehicleModel>> watchVehicles() => _repository.watchVehicles();
}
