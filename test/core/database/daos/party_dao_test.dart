import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('PartyDao', () {
    test('insert and lookup by id and name', () async {
      final id = await seedParty(db, name: 'ACME', mobile: '9000000000');
      final byId = await db.partyDao.getPartyById(id);
      expect(byId, isNotNull);
      expect(byId!.name, 'ACME');
      expect(byId.isActive, isTrue);

      final byName = await db.partyDao.getPartyByName('ACME');
      expect(byName, isNotNull);
      expect(byName!.id, id);
    });

    test('inserts inactive parties and filters them', () async {
      await seedParty(db, name: 'Active One');
      await seedParty(db, name: 'Inactive One', isActive: false);

      final active = await db.partyDao.getAllActiveParties();
      expect(active.map((p) => p.name), ['Active One']);

      final byStatusInactive = await db.partyDao.getPartiesByStatus(
        isActive: false,
      );
      expect(byStatusInactive.single.name, 'Inactive One');

      final all = await db.partyDao.getAllParties();
      expect(all.length, 2);
    });

    test('counts active/inactive/total parties', () async {
      await seedParty(db, name: 'A');
      await seedParty(db, name: 'B', isActive: false);
      await seedParty(db, name: 'C');

      expect(await db.partyDao.partyCount(), 3);
      expect(await db.partyDao.activePartyCount(), 2);
      expect(await db.partyDao.inactivePartyCount(), 1);
    });

    test('searchParties matches name, mobile, contactPerson or GST', () async {
      await seedParty(
        db,
        name: 'ACME Traders',
        mobile: '9876543211',
        contactPerson: 'Rajesh',
        gstNumber: '33ABCDE1234F1Z5',
      );
      await seedParty(db, name: 'Other Firm');

      expect((await db.partyDao.searchParties('acme')).single.name, 'ACME Traders');
      expect((await db.partyDao.searchParties('987654')).single.name, 'ACME Traders');
      expect((await db.partyDao.searchParties('Rajesh')).single.name, 'ACME Traders');
      expect((await db.partyDao.searchParties('33ABCDE')).single.name, 'ACME Traders');
      expect(await db.partyDao.searchParties('nomatch'), isEmpty);
    });

    test('deactivateParty flips isActive and touches updatedAt', () async {
      final id = await seedParty(db, name: 'To Deactivate');
      await db.partyDao.deactivateParty(id);

      final party = await db.partyDao.getPartyById(id);
      expect(party!.isActive, isFalse);
      expect(await db.partyDao.activePartyCount(), 0);
    });

    test('updateParty replaces fields', () async {
      final id = await seedParty(db, name: 'Before');
      final updated = await db.partyDao.updateParty(
        PartiesCompanion(
          id: Value(id),
          name: const Value('After'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      expect(updated, isTrue);
      final party = await db.partyDao.getPartyById(id);
      expect(party!.name, 'After');
      expect(party.isActive, isTrue);
    });

    test('deleteParty removes the record and returns deleted count', () async {
      final id = await seedParty(db, name: 'Doomed');
      final deleted = await db.partyDao.deleteParty(id);
      expect(deleted, 1);
      expect(await db.partyDao.getPartyById(id), isNull);
    });
  });
}