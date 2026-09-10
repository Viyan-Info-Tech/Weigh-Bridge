import '../entities/party.dart';
import '../repositories/party_repository.dart';

class LoadPartiesUseCase {
  final PartyRepository _repository;

  LoadPartiesUseCase(this._repository);

  Future<List<Party>> call() async {
    return _repository.getActiveParties();
  }
}

class SearchPartiesUseCase {
  final PartyRepository _repository;

  SearchPartiesUseCase(this._repository);

  Future<List<Party>> call(String query) async {
    return _repository.searchParties(query);
  }
}
