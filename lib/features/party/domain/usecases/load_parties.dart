import '../entities/party.dart';
import '../repositories/party_repository.dart';

class LoadPartiesUseCase {
  final PartyRepository _repository;

  LoadPartiesUseCase(this._repository);

  Future<List<Party>> call({bool? isActive}) async {
    if (isActive != null) {
      return await _repository.getPartiesByStatus(isActive: isActive);
    }
    return await _repository.getAllParties();
  }
}
