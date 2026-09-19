import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  test('schema version is 13', () {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    expect(db.schemaVersion, 13);
  });

  test('onCreate creates all application tables', () async {
    await withDatabase((db) async {
      final tables = [
        'users',
        'parties',
        'vehicle_types',
        'vehicles',
        'materials',
        'weighments',
        'app_settings',
      ];
      for (final table in tables) {
        final exists = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
          variables: [Variable.withString(table)],
        ).get();
        expect(
          exists,
          isNotEmpty,
          reason: 'table $table should exist after onCreate',
        );
      }
    });
  });

  test('database user_version is set to the schema version', () async {
    await withDatabase((db) async {
      final rows = await db.customSelect('PRAGMA user_version').get();
      expect(rows.single.data['user_version'], 13);
    });
  });

  test('can insert parents and a weighment referencing them', () async {
    await withDatabase((db) async {
      final refs = await seedParents(db);
      final id = await seedWeighment(
        db,
        partyId: refs.partyId,
        vehicleId: refs.vehicleId,
        materialId: refs.materialId,
        billNumber: 'WB-00001',
        firstWeightKg: 20000,
        secondWeightKg: 5000,
        status: 'completed',
      );
      expect(id, greaterThan(0));

      final stored = await db.billDao.getWeighmentById(id);
      expect(stored, isNotNull);
      expect(stored!.billNumber, 'WB-00001');
    });
  });

  test('bill_number unique constraint rejects duplicates', () async {
    await withDatabase((db) async {
      final refs = await seedParents(db);
      await seedWeighment(
        db,
        partyId: refs.partyId,
        vehicleId: refs.vehicleId,
        materialId: refs.materialId,
        billNumber: 'WB-00001',
      );
      expect(
        () => seedWeighment(
          db,
          partyId: refs.partyId,
          vehicleId: refs.vehicleId,
          materialId: refs.materialId,
          billNumber: 'WB-00001',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}