import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/material/data/datasources/material_item_local_datasource.dart';
import 'package:weighbridge/features/material/data/repositories/material_item_repository_impl.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';

class MockMaterialLocalDataSource extends Mock
    implements MaterialItemLocalDataSource {}

void main() {
  late MockMaterialLocalDataSource mockDataSource;
  late MaterialItemRepositoryImpl repository;

  final now = DateTime(2026, 9, 21);

  final testMaterial = MaterialItem(
    id: 1,
    code: '1',
    name: 'Cement',
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockDataSource = MockMaterialLocalDataSource();
    repository = MaterialItemRepositoryImpl(localDataSource: mockDataSource);
  });

  group('MaterialItemRepositoryImpl', () {
    group('getAllMaterials', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.getAllMaterials(),
        ).thenAnswer((_) async => [testMaterial]);

        final result = await repository.getAllMaterials();
        expect(result, [testMaterial]);
        verify(() => mockDataSource.getAllMaterials()).called(1);
      });
    });

    group('getMaterialsByStatus', () {
      test('delegates to datasource with isActive parameter', () async {
        when(
          () => mockDataSource.getMaterialsByStatus(isActive: true),
        ).thenAnswer((_) async => [testMaterial]);

        final result = await repository.getMaterialsByStatus(isActive: true);
        expect(result, [testMaterial]);
      });
    });

    group('getMaterialById', () {
      test('returns material when found', () async {
        when(
          () => mockDataSource.getMaterialById(1),
        ).thenAnswer((_) async => testMaterial);

        final result = await repository.getMaterialById(1);
        expect(result, testMaterial);
      });

      test('returns null when not found', () async {
        when(
          () => mockDataSource.getMaterialById(999),
        ).thenAnswer((_) async => null);

        final result = await repository.getMaterialById(999);
        expect(result, isNull);
      });
    });

    group('getMaterialByCode', () {
      test('returns material when found', () async {
        when(
          () => mockDataSource.getMaterialByCode('1'),
        ).thenAnswer((_) async => testMaterial);

        final result = await repository.getMaterialByCode('1');
        expect(result, testMaterial);
      });

      test('returns null when not found', () async {
        when(
          () => mockDataSource.getMaterialByCode('999'),
        ).thenAnswer((_) async => null);

        final result = await repository.getMaterialByCode('999');
        expect(result, isNull);
      });
    });

    group('createMaterial', () {
      test('delegates to datasource and returns id', () async {
        when(
          () => mockDataSource.insertMaterial(code: '9', name: 'Steel'),
        ).thenAnswer((_) async => 42);

        final id = await repository.createMaterial(code: '9', name: 'Steel');

        expect(id, 42);
        verify(
          () => mockDataSource.insertMaterial(code: '9', name: 'Steel'),
        ).called(1);
      });
    });

    group('updateMaterial', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.updateMaterial(
            id: 1,
            code: '4',
            name: 'Premium Cement',
          ),
        ).thenAnswer((_) async => true);

        final result = await repository.updateMaterial(
          id: 1,
          code: '4',
          name: 'Premium Cement',
        );

        expect(result, isTrue);
      });
    });

    group('deactivateMaterial', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.deactivateMaterial(1),
        ).thenAnswer((_) async {});

        await repository.deactivateMaterial(1);
        verify(() => mockDataSource.deactivateMaterial(1)).called(1);
      });
    });

    group('activateMaterial', () {
      test('delegates to datasource', () async {
        when(() => mockDataSource.activateMaterial(1)).thenAnswer((_) async {});

        await repository.activateMaterial(1);
        verify(() => mockDataSource.activateMaterial(1)).called(1);
      });
    });

    group('deleteMaterial', () {
      test('delegates to datasource', () async {
        when(() => mockDataSource.deleteMaterial(1)).thenAnswer((_) async {});

        await repository.deleteMaterial(1);
        verify(() => mockDataSource.deleteMaterial(1)).called(1);
      });
    });

    group('searchMaterials', () {
      test('delegates to datasource with query', () async {
        when(
          () => mockDataSource.searchMaterials('Cement'),
        ).thenAnswer((_) async => [testMaterial]);

        final result = await repository.searchMaterials('Cement');
        expect(result, [testMaterial]);
      });
    });
  });
}
