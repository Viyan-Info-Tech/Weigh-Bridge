import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/material/domain/usecases/create_material.dart';
import 'package:weighbridge/features/material/domain/usecases/delete_material.dart';
import 'package:weighbridge/features/material/domain/usecases/load_materials.dart';

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

void main() {
  late MockMaterialRepository mockRepository;

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
    mockRepository = MockMaterialRepository();
  });

  group('LoadMaterialsUseCase', () {
    test('loads all materials when no filter', () async {
      when(
        () => mockRepository.getAllMaterials(),
      ).thenAnswer((_) async => [testMaterial]);

      final useCase = LoadMaterialsUseCase(mockRepository);
      final result = await useCase();

      expect(result, [testMaterial]);
      verify(() => mockRepository.getAllMaterials()).called(1);
    });

    test('loads active materials when filterActive is true', () async {
      when(
        () => mockRepository.getMaterialsByStatus(isActive: true),
      ).thenAnswer((_) async => [testMaterial]);

      final useCase = LoadMaterialsUseCase(mockRepository);
      final result = await useCase(isActive: true);

      expect(result, [testMaterial]);
    });
  });

  group('CreateMaterialUseCase', () {
    test('creates material when code is unique', () async {
      when(
        () => mockRepository.getMaterialByCode('1'),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.createMaterial(code: '1', name: 'Cement'),
      ).thenAnswer((_) async => 42);

      final useCase = CreateMaterialUseCase(mockRepository);
      final id = await useCase(code: '1', name: 'Cement');

      expect(id, 42);
    });

    test('throws when material with same code exists', () async {
      when(
        () => mockRepository.getMaterialByCode('1'),
      ).thenAnswer((_) async => testMaterial);

      final useCase = CreateMaterialUseCase(mockRepository);

      expect(
        () => useCase(code: '1', name: 'Cement'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('already exists'),
          ),
        ),
      );
    });
  });

  group('DeleteMaterialUseCase', () {
    test('delegates to repository', () async {
      when(() => mockRepository.deleteMaterial(1)).thenAnswer((_) async {});

      final useCase = DeleteMaterialUseCase(mockRepository);
      await useCase(1);

      verify(() => mockRepository.deleteMaterial(1)).called(1);
    });
  });
}
