import '../repositories/party_repository.dart';

class CreatePartyUseCase {
  final PartyRepository _repository;

  CreatePartyUseCase(this._repository);

  Future<int> call({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    final existingParties = await _repository.searchParties(name);
    final exactMatch = existingParties.where((p) => p.name.toLowerCase() == name.toLowerCase());
    if (exactMatch.isNotEmpty) {
      throw Exception('Party with this name already exists');
    }

    return await _repository.createParty(
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
    );
  }
}
