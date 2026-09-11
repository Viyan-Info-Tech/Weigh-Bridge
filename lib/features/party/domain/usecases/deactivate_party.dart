import '../repositories/party_repository.dart';

class DeactivatePartyUseCase {
  final PartyRepository _repository;

  DeactivatePartyUseCase(this._repository);

  Future<void> call(int partyId) async {
    await _repository.deactivateParty(partyId);
  }
}
