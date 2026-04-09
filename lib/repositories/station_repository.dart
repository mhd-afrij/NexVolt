import '../core/services/firestore_service.dart';
import '../models/station_model.dart';

class StationRepository {
  StationRepository(this._repository);

  final AppRepository _repository;

  Stream<List<StationModel>> watchFavoriteStations() =>
      _repository.watchFavoriteStations();
}
