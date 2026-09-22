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
    test('insert and lookup by id, code and name', () async {
      final id = await seedMaterial(db, code: '1', name: 'Cement');
      final byId = await db.materialDao.getMaterialById(id);
      expect(byId, isNotNull);
      expect(byId!.code, '1');
      expect(byId.name, 'Cement');
      expect(byId.isActive, isTrue);

      final byCode = await db.materialDao.getMaterialByCode('1');
      expect(byCode, isNotNull);
      expect(byCode!.id, id);

      final byName = await db.materialDao.getMaterialByName('Cement');
      expect(byName, isNotNull);
      expect(byName!.id, id);
    });

    test('filters active/inactive and rejects duplicate codes', () async {
      await seedMaterial(db, code: '1', name: 'Cement');
      await seedMaterial(db, code: '2', name: 'Steel');
      await seedMaterial(db, code: '3', name: 'Sand', isActive: false);

      expect(
        (await db.materialDao.getAllActiveMaterials()).map((m) => m.name),
        ['Cement', 'Steel'],
      );
      expect(
        (await db.materialDao.getMaterialsByStatus(
          isActive: false,
        )).single.name,
        'Sand',
      );
      expect(
        () => seedMaterial(db, code: '1', name: 'Duplicate Code'),
        throwsA(isA<Exception>()),
      );
    });

    test('searchMaterials matches code or name', () async {
      await seedMaterial(db, code: 'C1', name: 'Cement');
      await seedMaterial(db, code: 'SR1', name: 'Steel Rebar');

      expect(
        (await db.materialDao.searchMaterials('cem')).single.name,
        'Cement',
      );
      expect(
        (await db.materialDao.searchMaterials('SR1')).single.name,
        'Steel Rebar',
      );
      expect(await db.materialDao.searchMaterials('zzz'), isEmpty);
    });

    test('material names may repeat but codes must be unique', () async {
      // Names are not unique in the current schema, but codes are.
      final first = await seedMaterial(db, code: '1', name: 'Cement');
      final second = await seedMaterial(db, code: '2', name: 'Cement');
      expect(first, isNot(second));
      expect((await db.materialDao.getAllMaterials()).length, 2);
      expect(
        () => seedMaterial(db, code: '1', name: 'Another Cement'),
        throwsA(isA<Exception>()),
      );
    });

    test('deactivate and activate toggle isActive', () async {
      final id = await seedMaterial(db, code: '1', name: 'Cement');
      await db.materialDao.deactivateMaterial(id);
      expect((await db.materialDao.getMaterialById(id))!.isActive, isFalse);

      await db.materialDao.activateMaterial(id);
      expect((await db.materialDao.getMaterialById(id))!.isActive, isTrue);
    });

    test('updateMaterial replaces fields', () async {
      final id = await seedMaterial(db, code: '1', name: 'Cement');
      await db.materialDao.updateMaterial(
        MaterialsCompanion(
          id: Value(id),
          code: const Value('4'),
          name: const Value('Cem Plus'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final m = await db.materialDao.getMaterialById(id);
      expect(m!.code, '4');
      expect(m.name, 'Cem Plus');
    });

    test('deleteMaterial removes the record', () async {
      final id = await seedMaterial(db, code: '1', name: 'Cement');
      final deleted = await db.materialDao.deleteMaterial(id);
      expect(deleted, 1);
      expect(await db.materialDao.getMaterialById(id), isNull);
    });
  });
}
