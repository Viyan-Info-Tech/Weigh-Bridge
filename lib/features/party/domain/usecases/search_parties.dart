import '../entities/party.dart';
import '../repositories/party_repository.dart';

class SearchPartiesUseCase {
  final PartyRepository _repository;

  SearchPartiesUseCase(this._repository);

  Future<List<Party>> call(String query) async {
    return await _repository.searchParties(query);
  }
}
