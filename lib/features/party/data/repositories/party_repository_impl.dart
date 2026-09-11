import '../../domain/entities/party.dart';
import '../../domain/repositories/party_repository.dart';
import '../datasources/party_local_datasource.dart';

class PartyRepositoryImpl implements PartyRepository {
  final PartyLocalDataSource _dataSource;

  PartyRepositoryImpl(PartyLocalDataSource partyLocalDataSource)
      : _dataSource = partyLocalDataSource;

  @override
  Future<List<Party>> getAllParties() async {
    return await _dataSource.getAllParties();
  }

  @override
  Future<List<Party>> getAllActiveParties() async {
    return await _dataSource.getAllActiveParties();
  }

  @override
  Future<List<Party>> getPartiesByStatus({required bool isActive}) async {
    return await _dataSource.getPartiesByStatus(isActive: isActive);
  }

  @override
  Future<Party?> getPartyById(int id) async {
    return await _dataSource.getPartyById(id);
  }

  @override
  Future<int> createParty({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return await _dataSource.createParty(
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

  @override
  Future<bool> updateParty({
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
    return await _dataSource.updateParty(
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

  @override
  Future<void> deactivateParty(int id) async {
    await _dataSource.deactivateParty(id);
  }

  @override
  Future<List<Party>> searchParties(String query) async {
    return await _dataSource.searchParties(query);
  }

  @override
  Future<int> totalPartyCount() async {
    return await _dataSource.totalPartyCount();
  }

  @override
  Future<int> activePartyCount() async {
    return await _dataSource.activePartyCount();
  }

  @override
  Future<int> inactivePartyCount() async {
    return await _dataSource.inactivePartyCount();
  }
}
