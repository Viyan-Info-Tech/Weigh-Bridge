import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Party;
import '../../domain/entities/party.dart';

class PartyLocalDataSource {
  final AppDatabase _database;

  PartyLocalDataSource(this._database);

  Future<List<Party>> getAllParties() async {
    final records = await _database.partyDao.getAllParties();
    return records.map(_toEntity).toList();
  }

  Future<List<Party>> getAllActiveParties() async {
    final records = await _database.partyDao.getAllActiveParties();
    return records.map(_toEntity).toList();
  }

  Future<List<Party>> getPartiesByStatus({required bool isActive}) async {
    final records = await _database.partyDao.getPartiesByStatus(isActive: isActive);
    return records.map(_toEntity).toList();
  }

  Future<Party?> getPartyById(int id) async {
    final record = await _database.partyDao.getPartyById(id);
    return record != null ? _toEntity(record) : null;
  }

  Future<Party?> getPartyByName(String name) async {
    final record = await _database.partyDao.getPartyByName(name);
    return record != null ? _toEntity(record) : null;
  }

  Future<int> insertParty({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return _database.partyDao.insertParty(PartiesCompanion(
      name: Value(name),
      contactPerson: Value(contactPerson),
      mobile: Value(mobile),
      email: Value(email),
      address: Value(address),
      gstNumber: Value(gstNumber),
      city: Value(city),
      state: Value(state),
    ));
  }

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
    return _database.partyDao.updateParty(PartiesCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: Value(contactPerson),
      mobile: Value(mobile),
      email: Value(email),
      address: Value(address),
      gstNumber: Value(gstNumber),
      city: Value(city),
      state: Value(state),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deactivateParty(int id) async {
    await _database.partyDao.deactivateParty(id);
  }

  Future<List<Party>> searchParties(String query) async {
    final records = await _database.partyDao.searchParties(query);
    return records.map(_toEntity).toList();
  }

  Future<int> partyCount() => _database.partyDao.partyCount();
  Future<int> activePartyCount() => _database.partyDao.activePartyCount();
  Future<int> inactivePartyCount() => _database.partyDao.inactivePartyCount();
  Future<int> partyVehicleCount(int partyId) => _database.partyDao.partyVehicleCount(partyId);

  Party _toEntity(dynamic record) {
    return Party(
      id: record.id,
      name: record.name,
      contactPerson: record.contactPerson,
      mobile: record.mobile,
      email: record.email,
      address: record.address,
      gstNumber: record.gstNumber,
      city: record.city,
      state: record.state,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
