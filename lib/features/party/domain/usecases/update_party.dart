import '../repositories/party_repository.dart';

class UpdatePartyUseCase {
  final PartyRepository _repository;

  UpdatePartyUseCase(this._repository);

  Future<bool> call({
    required int id,
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return await _repository.updateParty(
      id: id,
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
