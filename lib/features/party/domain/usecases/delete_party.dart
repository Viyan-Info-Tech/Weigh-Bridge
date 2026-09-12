import '../repositories/party_repository.dart';

class DeletePartyUseCase {
  final PartyRepository _repository;

  DeletePartyUseCase(this._repository);

  Future<void> call(int partyId) async {
    await _repository.deleteParty(partyId);
  }
}
