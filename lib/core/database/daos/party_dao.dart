import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/parties_table.dart';

part 'party_dao.g.dart';

@DriftAccessor(tables: [Parties])
class PartyDao extends DatabaseAccessor<AppDatabase> with _$PartyDaoMixin {
  PartyDao(super.db);

  Future<List<Party>> getAllActiveParties() async {
    final query = select(parties)..where((p) => p.isActive.equals(true));
    return query.get();
  }

  Future<List<Party>> getAllParties() async {
    return select(parties).get();
  }

  Future<List<Party>> getPartiesByStatus({required bool isActive}) async {
    final query = select(parties)..where((p) => p.isActive.equals(isActive));
    return query.get();
  }

  Future<Party?> getPartyById(int id) async {
    final query = select(parties)..where((p) => p.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Party?> getPartyByName(String name) async {
    final query = select(parties)..where((p) => p.name.equals(name));
    return query.getSingleOrNull();
  }

  Future<int> insertParty(PartiesCompanion entry) async {
    return into(parties).insert(entry);
  }

  Future<bool> updateParty(PartiesCompanion entry) async {
    return update(parties).replace(entry);
  }

  Future<int> partyCount() async {
    final count = parties.id.count();
    final query = selectOnly(parties)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> activePartyCount() async {
    final count = parties.id.count();
    final query = selectOnly(parties)
      ..addColumns([count])
      ..where(parties.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> inactivePartyCount() async {
    final count = parties.id.count();
    final query = selectOnly(parties)
      ..addColumns([count])
      ..where(parties.isActive.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<Party>> searchParties(String query) async {
    final q = select(parties)
      ..where((p) =>
          p.name.like('%$query%') |
          p.mobile.like('%$query%') |
          p.contactPerson.like('%$query%') |
          p.gstNumber.like('%$query%'))
      ..limit(20);
    return q.get();
  }

  Future<void> deactivateParty(int id) async {
    final now = DateTime.now();
    await (update(parties)..where((p) => p.id.equals(id)))
        .write(PartiesCompanion(
      isActive: const Value(false),
      updatedAt: Value(now),
    ));
  }

  Future<int> deleteParty(int id) async {
    return await (delete(parties)..where((p) => p.id.equals(id))).go();
  }
}
