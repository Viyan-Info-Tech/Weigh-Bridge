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

  group('MaterialDao', () {
    test('insert and lookup by id and name', () async {
      final id = await seedMaterial(db, name: 'Cement', category: 'Building');
      final byId = await db.materialDao.getMaterialById(id);
      expect(byId, isNotNull);
      expect(byId!.name, 'Cement');
      expect(byId.category, 'Building');
      expect(byId.isActive, isTrue);

      final byName = await db.materialDao.getMaterialByName('Cement');
      expect(byName, isNotNull);
      expect(byName!.id, id);
    });

    test('filters active/inactive and by category', () async {
      await seedMaterial(db, name: 'Cement', category: 'Building');
      await seedMaterial(db, name: 'Steel', category: 'Building');
      await seedMaterial(db, name: 'Sand', category: 'Aggregate', isActive: false);

      expect(
        (await db.materialDao.getAllActiveMaterials()).map((m) => m.name),
        ['Cement', 'Steel'],
      );
      expect(
        (await db.materialDao.getMaterialsByCategory('Building'))
            .map((m) => m.name),
        ['Cement', 'Steel'],
      );
      expect(
        (await db.materialDao.getMaterialsByCategory('Aggregate')),
        isEmpty,
      );
      expect(
        (await db.materialDao.getMaterialsByStatus(isActive: false)).single.name,
        'Sand',
      );
    });

    test('searchMaterials matches name or category', () async {
      await seedMaterial(db, name: 'Cement', category: 'Building');
      await seedMaterial(db, name: 'Steel Rebar', category: 'Metal');

      expect((await db.materialDao.searchMaterials('cem')).single.name, 'Cement');
      expect((await db.materialDao.searchMaterials('metal')).single.name, 'Steel Rebar');
      expect(await db.materialDao.searchMaterials('zzz'), isEmpty);
    });

    test('material names are not unique in the current schema', () async {
      // The materials table has no UNIQUE index on name. This documents that,
      // unlike vehicles/parties/users, duplicate material names are permitted.
      final first = await seedMaterial(db, name: 'Cement');
      final second = await seedMaterial(db, name: 'Cement');
      expect(first, isNot(second));
      expect(
        (await db.materialDao.getAllMaterials()).length,
        2,
      );
    });

    test('deactivate and activate toggle isActive', () async {
      final id = await seedMaterial(db, name: 'Cement');
      await db.materialDao.deactivateMaterial(id);
      expect((await db.materialDao.getMaterialById(id))!.isActive, isFalse);

      await db.materialDao.activateMaterial(id);
      expect((await db.materialDao.getMaterialById(id))!.isActive, isTrue);
    });

    test('updateMaterial replaces fields', () async {
      final id = await seedMaterial(db, name: 'Cement', category: 'Building');
      await db.materialDao.updateMaterial(
        MaterialsCompanion(
          id: Value(id),
          name: const Value('Cem Plus'),
          category: const Value('Premium'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final m = await db.materialDao.getMaterialById(id);
      expect(m!.name, 'Cem Plus');
      expect(m.category, 'Premium');
    });

    test('deleteMaterial removes the record', () async {
      final id = await seedMaterial(db, name: 'Cement');
      final deleted = await db.materialDao.deleteMaterial(id);
      expect(deleted, 1);
      expect(await db.materialDao.getMaterialById(id), isNull);
    });
  });
}