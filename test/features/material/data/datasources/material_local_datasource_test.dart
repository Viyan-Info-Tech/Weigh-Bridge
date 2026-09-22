import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/material/data/datasources/material_item_local_datasource.dart';

import '../../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late MaterialItemLocalDataSource source;

  setUp(() async {
    db = createInMemoryDatabase();
    source = MaterialItemLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MaterialItemLocalDataSource', () {
    group('insertMaterial', () {
      test('creates a material and returns the id', () async {
        final id = await source.insertMaterial(
          code: '1',
          name: 'Portland Cement',
        );
        expect(id, greaterThan(0));
      });

      test('creates a material with minimal fields', () async {
        final id = await source.insertMaterial(code: '2', name: 'Sand');
        expect(id, greaterThan(0));

        final material = await source.getMaterialById(id);
        expect(material, isNotNull);
        expect(material!.name, 'Sand');
        expect(material.code, '2');
      });

      test('creates material with Tamil text', () async {
        final id = await source.insertMaterial(code: '3', name: 'தமிழ் பொருள்');
        final material = await source.getMaterialById(id);
        expect(material!.name, 'தமிழ் பொருள்');
      });
    });

    group('getAllMaterials', () {
      test('returns empty list when no materials exist', () async {
        final materials = await source.getAllMaterials();
        expect(materials, isEmpty);
      });

      test('returns all materials', () async {
        await source.insertMaterial(code: '1', name: 'Cement');
        await source.insertMaterial(code: '2', name: 'Steel');

        final materials = await source.getAllMaterials();
        expect(materials.length, 2);
      });
    });

    group('getMaterialsByStatus', () {
      test('filters by active status', () async {
        final id1 = await source.insertMaterial(
          code: '1',
          name: 'Active Material',
        );
        await source.insertMaterial(code: '2', name: 'Inactive Material');
        final allMaterials = await source.getAllMaterials();
        final id2 = allMaterials
            .firstWhere((m) => m.name == 'Inactive Material')
            .id;
        await source.deactivateMaterial(id2);

        final active = await source.getMaterialsByStatus(isActive: true);
        expect(active.length, 1);
        expect(active.first.id, id1);

        final inactive = await source.getMaterialsByStatus(isActive: false);
        expect(inactive.length, 1);
        expect(inactive.first.name, 'Inactive Material');
      });
    });

    group('getMaterialById', () {
      test('returns null for nonexistent id', () async {
        final material = await source.getMaterialById(9999);
        expect(material, isNull);
      });

      test('returns material by id', () async {
        final id = await source.insertMaterial(code: '10', name: 'Lookup Test');
        final material = await source.getMaterialById(id);
        expect(material, isNotNull);
        expect(material!.name, 'Lookup Test');
      });
    });

    group('getMaterialByCode', () {
      test('returns the matching material by code', () async {
        await source.insertMaterial(code: '5', name: 'Cement');
        final material = await source.getMaterialByCode('5');
        expect(material, isNotNull);
        expect(material!.name, 'Cement');
      });

      test('returns null for a missing code', () async {
        final material = await source.getMaterialByCode('999');
        expect(material, isNull);
      });
    });

    group('updateMaterial', () {
      test('updates material fields', () async {
        final id = await source.insertMaterial(code: '1', name: 'Cement');
        final result = await source.updateMaterial(
          id: id,
          code: '4',
          name: 'Premium Cement',
        );
        expect(result, isTrue);

        final updated = await source.getMaterialById(id);
        expect(updated!.code, '4');
        expect(updated.name, 'Premium Cement');
      });
    });

    group('deactivateMaterial', () {
      test('sets isActive to false', () async {
        final id = await source.insertMaterial(code: '1', name: 'Cement');
        await source.deactivateMaterial(id);

        final material = await source.getMaterialById(id);
        expect(material!.isActive, isFalse);
      });
    });

    group('activateMaterial', () {
      test('sets isActive to true', () async {
        final id = await source.insertMaterial(code: '1', name: 'Cement');
        await source.deactivateMaterial(id);
        expect((await source.getMaterialById(id))!.isActive, isFalse);

        await source.activateMaterial(id);
        expect((await source.getMaterialById(id))!.isActive, isTrue);
      });
    });

    group('deleteMaterial', () {
      test('removes the material', () async {
        final id = await source.insertMaterial(code: '1', name: 'Cement');
        await source.deleteMaterial(id);

        final material = await source.getMaterialById(id);
        expect(material, isNull);
      });

      test('delete nonexistent material does not throw', () async {
        await source.deleteMaterial(9999);
      });
    });

    group('searchMaterials', () {
      test('searches by name', () async {
        await source.insertMaterial(code: 'PC1', name: 'Portland Cement');
        await source.insertMaterial(code: 'SR1', name: 'Steel Rebar');

        final results = await source.searchMaterials('Cement');
        expect(results.length, 1);
        expect(results.first.name, 'Portland Cement');
      });

      test('searches by code', () async {
        await source.insertMaterial(code: 'SR1', name: 'Steel Rebar');

        final results = await source.searchMaterials('SR');
        expect(results.length, 1);
        expect(results.first.code, 'SR1');
      });

      test('case-insensitive search', () async {
        await source.insertMaterial(code: 'PC1', name: 'Cement');

        final results = await source.searchMaterials('cement');
        expect(results.length, 1);
      });

      test('returns empty for no match', () async {
        await source.insertMaterial(code: 'PC1', name: 'Cement');
        final results = await source.searchMaterials('zzz-nothing');
        expect(results, isEmpty);
      });
    });

    group('duplicate codes', () {
      test(
        'duplicate material names are allowed with distinct codes',
        () async {
          final id1 = await source.insertMaterial(code: '1', name: 'Cement');
          final id2 = await source.insertMaterial(code: '2', name: 'Cement');
          expect(id1, isNot(id2));

          final all = await source.getAllMaterials();
          expect(all.length, 2);
        },
      );

      test('duplicate material codes are rejected', () async {
        await source.insertMaterial(code: '1', name: 'Cement');
        expect(
          () => source.insertMaterial(code: '1', name: 'Steel'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
