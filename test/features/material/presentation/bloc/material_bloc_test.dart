import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/material/domain/usecases/create_material.dart';
import 'package:weighbridge/features/material/domain/usecases/delete_material.dart';
import 'package:weighbridge/features/material/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_bloc.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_event.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_state.dart';

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockLoadMaterialsUseCase extends Mock implements LoadMaterialsUseCase {}

class MockCreateMaterialUseCase extends Mock implements CreateMaterialUseCase {}

class MockDeleteMaterialUseCase extends Mock implements DeleteMaterialUseCase {}

void main() {
  late MaterialBloc bloc;
  late MockMaterialRepository mockRepository;
  late MockLoadMaterialsUseCase mockLoadUseCase;
  late MockCreateMaterialUseCase mockCreateUseCase;
  late MockDeleteMaterialUseCase mockDeleteUseCase;

  final now = DateTime(2026, 9, 21);

  final testMaterial = MaterialItem(
    id: 1,
    code: '1',
    name: 'Cement',
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );

  /// Set up mocks for the follow-up LoadMaterials call that the BLoC
  /// dispatches internally after success events.
  void setUpLoadMaterialsMocks({List<MaterialItem>? materials}) {
    when(
      () => mockLoadUseCase(isActive: any(named: 'isActive')),
    ).thenAnswer((_) async => materials ?? [testMaterial]);
  }

  setUp(() {
    mockRepository = MockMaterialRepository();
    mockLoadUseCase = MockLoadMaterialsUseCase();
    mockCreateUseCase = MockCreateMaterialUseCase();
    mockDeleteUseCase = MockDeleteMaterialUseCase();

    bloc = MaterialBloc(
      loadMaterialsUseCase: mockLoadUseCase,
      createMaterialUseCase: mockCreateUseCase,
      deleteMaterialUseCase: mockDeleteUseCase,
      materialRepository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  /// Collect all states emitted while [action] runs, including follow-up states.
  Future<List<MaterialState>> collectStates(void Function() action) async {
    final states = <MaterialState>[];
    final sub = bloc.stream.listen(states.add);
    action();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    return states;
  }

  group('MaterialBloc', () {
    test('initial state is MaterialState.initial', () {
      expect(bloc.state.status, AppMaterialStatus.initial);
      expect(bloc.state.materials, isEmpty);
    });

    group('LoadMaterials', () {
      test('emits loading then loaded with materials', () async {
        when(
          () => mockLoadUseCase(isActive: null),
        ).thenAnswer((_) async => [testMaterial]);

        final states = await collectStates(() {
          bloc.add(const LoadMaterials());
        });

        expect(
          states.any((s) => s.status == AppMaterialStatus.loading),
          isTrue,
        );
        expect(states.any((s) => s.status == AppMaterialStatus.loaded), isTrue);
        expect(bloc.state.materials, [testMaterial]);
      });

      test('emits error when load fails', () async {
        when(
          () => mockLoadUseCase(isActive: null),
        ).thenThrow(Exception('Database error'));

        bloc.add(const LoadMaterials());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, AppMaterialStatus.error);
        expect(bloc.state.errorMessage, contains('Database error'));
      });

      test('loads active materials when filterActive is true', () async {
        when(
          () => mockLoadUseCase(isActive: true),
        ).thenAnswer((_) async => [testMaterial]);

        await collectStates(() {
          bloc.add(const LoadMaterials(filterActive: true));
        });

        expect(bloc.state.materials, [testMaterial]);
      });
    });

    group('LoadMaterialById', () {
      test('loads material by id', () async {
        when(
          () => mockRepository.getMaterialById(1),
        ).thenAnswer((_) async => testMaterial);

        bloc.add(const LoadMaterialById(1));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, AppMaterialStatus.loaded);
        expect(bloc.state.selectedMaterial, testMaterial);
      });
    });

    group('CreateMaterialRequested', () {
      test('emits success then follow-up loaded', () async {
        when(
          () => mockCreateUseCase(code: '1', name: 'New Material'),
        ).thenAnswer((_) async => 42);
        setUpLoadMaterialsMocks();

        final states = await collectStates(() {
          bloc.add(
            const CreateMaterialRequested(code: '1', name: 'New Material'),
          );
        });

        final successStates = states
            .where((s) => s.status == AppMaterialStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('created'));
        expect(bloc.state.status, AppMaterialStatus.loaded);
      });

      test('emits error when creation fails', () async {
        when(
          () => mockCreateUseCase(code: '1', name: 'Fail'),
        ).thenThrow(Exception('Duplicate'));

        bloc.add(const CreateMaterialRequested(code: '1', name: 'Fail'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, AppMaterialStatus.error);
      });
    });

    group('UpdateMaterialRequested', () {
      test('emits success then follow-up loaded', () async {
        when(
          () => mockRepository.getMaterialByCode('2'),
        ).thenAnswer((_) async => null);
        when(
          () =>
              mockRepository.updateMaterial(id: 1, code: '2', name: 'Updated'),
        ).thenAnswer((_) async => true);
        setUpLoadMaterialsMocks();

        final states = await collectStates(() {
          bloc.add(
            const UpdateMaterialRequested(id: 1, code: '2', name: 'Updated'),
          );
        });

        final successStates = states
            .where((s) => s.status == AppMaterialStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('updated'));
        expect(bloc.state.status, AppMaterialStatus.loaded);
      });

      test('emits error when code is used by another material', () async {
        when(() => mockRepository.getMaterialByCode('2')).thenAnswer(
          (_) async => MaterialItem(
            id: 5,
            code: '2',
            name: 'Other',
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final states = await collectStates(() {
          bloc.add(
            const UpdateMaterialRequested(id: 1, code: '2', name: 'Updated'),
          );
        });

        final errorStates = states
            .where((s) => s.status == AppMaterialStatus.error)
            .toList();
        expect(errorStates, isNotEmpty);
        expect(errorStates.last.errorMessage, contains('already exists'));
      });
    });

    group('DeactivateMaterialRequested', () {
      test('deactivates material and reloads', () async {
        when(
          () => mockRepository.deactivateMaterial(1),
        ).thenAnswer((_) async {});
        setUpLoadMaterialsMocks();

        final states = await collectStates(() {
          bloc.add(const DeactivateMaterialRequested(1));
        });

        final successStates = states
            .where((s) => s.status == AppMaterialStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('deactivated'));
        expect(bloc.state.status, AppMaterialStatus.loaded);
      });
    });

    group('ActivateMaterialRequested', () {
      test('activates material and reloads', () async {
        when(() => mockRepository.activateMaterial(1)).thenAnswer((_) async {});
        setUpLoadMaterialsMocks();

        final states = await collectStates(() {
          bloc.add(const ActivateMaterialRequested(1));
        });

        final successStates = states
            .where((s) => s.status == AppMaterialStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('activated'));
        expect(bloc.state.status, AppMaterialStatus.loaded);
      });
    });

    group('DeleteMaterialRequested', () {
      test('deletes material and reloads', () async {
        when(() => mockDeleteUseCase(1)).thenAnswer((_) async {});
        setUpLoadMaterialsMocks(materials: []);

        final states = await collectStates(() {
          bloc.add(const DeleteMaterialRequested(1));
        });

        final successStates = states
            .where((s) => s.status == AppMaterialStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('deleted'));
        expect(bloc.state.status, AppMaterialStatus.loaded);
      });
    });

    group('SearchMaterials', () {
      test('searches and returns results', () async {
        when(
          () => mockRepository.searchMaterials('Cement'),
        ).thenAnswer((_) async => [testMaterial]);

        bloc.add(const SearchMaterials('Cement'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, AppMaterialStatus.loaded);
        expect(bloc.state.materials, [testMaterial]);
        expect(bloc.state.searchQuery, 'Cement');
      });

      test('empty query triggers LoadMaterials', () async {
        setUpLoadMaterialsMocks();

        final states = await collectStates(() {
          bloc.add(const SearchMaterials(''));
        });

        expect(states.any((s) => s.status == AppMaterialStatus.loaded), isTrue);
      });
    });

    group('FilterMaterialsByStatus', () {
      test('delegates to LoadMaterials with filter', () async {
        setUpLoadMaterialsMocks();

        final states = await collectStates(() {
          bloc.add(const FilterMaterialsByStatus(true));
        });

        expect(states.any((s) => s.status == AppMaterialStatus.loaded), isTrue);
      });
    });
  });
}
