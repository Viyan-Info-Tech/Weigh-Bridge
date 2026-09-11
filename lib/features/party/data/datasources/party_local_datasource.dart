import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/party.dart' as domain;

class PartyLocalDataSource {
  final AppDatabase _database;

  PartyLocalDataSource(this._database);

  Future<List<domain.Party>> getAllParties() async {
    final records = await _database.partyDao.getAllParties();
    return records.map((r) => domain.Party(
      id: r.id,
      name: r.name,
      contactPerson: r.contactPerson,
      mobile: r.mobile,
      email: r.email,
      address: r.address,
      gstNumber: r.gstNumber,
      city: r.city,
      state: r.state,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  Future<List<domain.Party>> getAllActiveParties() async {
    final records = await _database.partyDao.getAllActiveParties();
    return records.map((r) => domain.Party(
      id: r.id,
      name: r.name,
      contactPerson: r.contactPerson,
      mobile: r.mobile,
      email: r.email,
      address: r.address,
      gstNumber: r.gstNumber,
      city: r.city,
      state: r.state,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  Future<List<domain.Party>> getPartiesByStatus({required bool isActive}) async {
    final records = await _database.partyDao.getPartiesByStatus(isActive: isActive);
    return records.map((r) => domain.Party(
      id: r.id,
      name: r.name,
      contactPerson: r.contactPerson,
      mobile: r.mobile,
      email: r.email,
      address: r.address,
      gstNumber: r.gstNumber,
      city: r.city,
      state: r.state,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  Future<domain.Party?> getPartyById(int id) async {
    final record = await _database.partyDao.getPartyById(id);
    if (record == null) return null;
    return domain.Party(
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
    return await _database.partyDao.insertParty(PartiesCompanion.insert(
      name: name,
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
    return await _database.partyDao.updateParty(PartiesCompanion(
      id: Value(id),
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

  Future<void> deactivateParty(int id) async {
    await _database.partyDao.deactivateParty(id);
  }

  Future<List<domain.Party>> searchParties(String query) async {
    final records = await _database.partyDao.searchParties(query);
    return records.map((r) => domain.Party(
      id: r.id,
      name: r.name,
      contactPerson: r.contactPerson,
      mobile: r.mobile,
      email: r.email,
      address: r.address,
      gstNumber: r.gstNumber,
      city: r.city,
      state: r.state,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  Future<int> totalPartyCount() async {
    return await _database.partyDao.partyCount();
  }

  Future<int> activePartyCount() async {
    return await _database.partyDao.activePartyCount();
  }

  Future<int> inactivePartyCount() async {
    return await _database.partyDao.inactivePartyCount();
  }
}
