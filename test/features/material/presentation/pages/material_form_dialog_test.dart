import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/material/domain/usecases/create_material.dart';
import 'package:weighbridge/features/material/domain/usecases/delete_material.dart';
import 'package:weighbridge/features/material/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_bloc.dart';
import 'package:weighbridge/features/material/presentation/pages/material_form_page.dart';

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

/// Enter in either field must run the same save path as the submit button,
/// and must not be able to fire two updates for one press sequence.
void main() {
  late MockMaterialRepository repository;

  const materialId = 7;
  final existing = MaterialItem(
    id: materialId,
    code: 'OLD',
    name: 'Old Name',
    isActive: true,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );

  MaterialBloc buildBloc() {
    return MaterialBloc(
      loadMaterialsUseCase: LoadMaterialsUseCase(repository),
      createMaterialUseCase: CreateMaterialUseCase(repository),
      deleteMaterialUseCase: DeleteMaterialUseCase(repository),
      materialRepository: repository,
    );
  }

  setUp(() {
    repository = MockMaterialRepository();

    when(
      () => repository.getMaterialById(materialId),
    ).thenAnswer((_) async => existing);
    // No duplicate: the code the operator typed belongs to the same record.
    when(
      () => repository.getMaterialByCode(any()),
    ).thenAnswer((_) async => null);
    when(
      () => repository.getMaterialByName(any()),
    ).thenAnswer((_) async => null);
    when(
      () => repository.updateMaterial(
        id: any(named: 'id'),
        code: any(named: 'code'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => repository.getAllMaterials(),
    ).thenAnswer((_) async => [existing]);
  });

  /// Pumps the edit dialog and returns once the loaded material has populated
  /// both fields.
  Future<void> pumpDialog(WidgetTester tester) async {
    final bloc = buildBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MaterialBloc>.value(
          value: bloc,
          child: const MaterialFormDialog(materialId: materialId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder codeField() => find.byKey(const Key('material_code_field'));
  Finder nameField() => find.byKey(const Key('material_name_field'));

  /// Enters text into the field identified by its key.
  Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
    await tester.enterText(field, text);
    await tester.pump();
  }

  group('Edit Material submits on Enter', () {
    testWidgets('Enter in Material Name updates the material', (tester) async {
      await pumpDialog(tester);

      await typeInto(tester, nameField(), 'Sand');

      // Enter on the name field is the submit action.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      verify(
        () => repository.updateMaterial(
          id: materialId,
          code: 'OLD',
          name: 'Sand',
        ),
      ).called(1);
    });

    testWidgets('Enter in Material Code updates the material', (tester) async {
      await pumpDialog(tester);

      await typeInto(tester, codeField(), 'NEW');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      verify(
        () => repository.updateMaterial(
          id: materialId,
          code: 'NEW',
          name: 'Old Name',
        ),
      ).called(1);
    });

    testWidgets('Enter and the submit button share one save path', (
      tester,
    ) async {
      await pumpDialog(tester);

      await typeInto(tester, nameField(), 'Gravel');
      await tester.tap(find.text('Update Material'));
      await tester.pumpAndSettle();

      verify(
        () => repository.updateMaterial(
          id: materialId,
          code: 'OLD',
          name: 'Gravel',
        ),
      ).called(1);
    });

    testWidgets('repeated Enter does not send a second update', (tester) async {
      await pumpDialog(tester);

      await typeInto(tester, nameField(), 'Sand');

      // Two Enters back to back, without settling in between, must not
      // produce two updates while the first is still in flight.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      verify(
        () => repository.updateMaterial(
          id: materialId,
          code: any(named: 'code'),
          name: any(named: 'name'),
        ),
      ).called(1);
    });

    testWidgets('Enter on an empty form shows validation and does not save', (
      tester,
    ) async {
      await pumpDialog(tester);

      // Clear both fields so validation fails.
      await typeInto(tester, nameField(), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Material name is required'), findsOneWidget);
      verifyNever(
        () => repository.updateMaterial(
          id: any(named: 'id'),
          code: any(named: 'code'),
          name: any(named: 'name'),
        ),
      );
    });
  });
}
