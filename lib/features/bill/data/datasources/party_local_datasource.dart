import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Party;
import '../../domain/entities/party.dart';

class PartyLocalDataSource {
  final AppDatabase _database;

  PartyLocalDataSource(this._database);

  Future<List<Party>> getActiveParties() async {
    final records = await _database.partyDao.getAllActiveParties();
    return records.map(_toEntity).toList();
  }

  Future<Party?> getPartyById(int id) async {
    final record = await _database.partyDao.getPartyById(id);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<List<Party>> searchParties(String query) async {
    final records = await _database.partyDao.searchParties(query);
    return records.map(_toEntity).toList();
  }

  Future<int> insertParty(String name, {String? mobile, String? address, String? gstNumber}) async {
    return _database.partyDao.insertParty(
      PartiesCompanion.insert(
        name: name,
        mobile: Value(mobile),
        address: Value(address),
        gstNumber: Value(gstNumber),
      ),
    );
  }

  Party _toEntity(dynamic record) {
    return Party(
      id: record.id,
      name: record.name,
      mobile: record.mobile,
      address: record.address,
      gstNumber: record.gstNumber,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
