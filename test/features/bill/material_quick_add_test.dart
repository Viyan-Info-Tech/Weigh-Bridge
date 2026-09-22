import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/widgets/quick_add_material_dialog.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

void main() {
  late BillBloc billBloc;
  late MockCustomerRepository mockCustomerRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  setUp(() {
    mockCustomerRepository = MockCustomerRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    billBloc = BillBloc(
      customerRepository: mockCustomerRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() {
    billBloc.close();
  });

  MaterialItem buildMaterial(int id, String code, String name) {
    return MaterialItem(
      id: id,
      code: code,
      name: name,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('Material Quick Add - BillBloc', () {
    test(
      'successfully creates material, updates state.materials and selectedMaterial',
      () async {
        final existingMaterials = [buildMaterial(1, '1', 'Sand')];

        final createdMaterial = buildMaterial(2, '2', 'Stone');

        when(
          () => mockMaterialRepository.getAllMaterials(),
        ).thenAnswer((_) async => existingMaterials);
        when(
          () => mockMaterialRepository.getMaterialByCode('2'),
        ).thenAnswer((_) async => null);
        when(
          () => mockMaterialRepository.createMaterial(code: '2', name: 'Stone'),
        ).thenAnswer((_) async => 2);
        when(
          () => mockMaterialRepository.getMaterialById(2),
        ).thenAnswer((_) async => createdMaterial);

        final result = await billBloc.quickAddMaterial('2', 'Stone');

        expect(result, equals(createdMaterial));
        expect(billBloc.state.materials.any((m) => m.name == 'Stone'), isTrue);
        expect(billBloc.state.selectedMaterial, equals(createdMaterial));
        expect(billBloc.state.errorMessage, isNull);
      },
    );

    test('prevents duplicate material codes', () async {
      final existingMaterial = buildMaterial(1, '1', 'Stone');

      when(
        () => mockMaterialRepository.getMaterialByCode('1'),
      ).thenAnswer((_) async => existingMaterial);

      expect(
        () => billBloc.quickAddMaterial('1', 'Stone'),
        throwsA(isA<Exception>()),
      );

      // Wait a microtask for state emission
      await Future<void>.delayed(Duration.zero);
      expect(billBloc.state.errorMessage, contains('already exists'));
    });

    test('prevents empty material name', () async {
      expect(
        () => billBloc.quickAddMaterial('1', '   '),
        throwsA(isA<Exception>()),
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        billBloc.state.errorMessage,
        contains('Material name is required'),
      );
    });

    test('prevents empty material code', () async {
      expect(
        () => billBloc.quickAddMaterial('   ', 'Stone'),
        throwsA(isA<Exception>()),
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        billBloc.state.errorMessage,
        contains('Material code is required'),
      );
    });
  });

  group('QuickAddMaterialDialog Widget Tests', () {
    testWidgets('renders dialog and validates empty fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddMaterialDialog.show(
                  context,
                  onSave: (code, name) async => null,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Add Material'), findsOneWidget);
      expect(find.text('Material Code *'), findsOneWidget);
      expect(find.text('Material Name *'), findsOneWidget);

      // Try to save empty
      await tester.tap(find.text('Save Material'));
      await tester.pumpAndSettle();

      expect(find.text('Material code is required'), findsOneWidget);
      expect(find.text('Material name is required'), findsOneWidget);
    });

    testWidgets('shows loading and returns created material on success', (
      tester,
    ) async {
      final createdItem = buildMaterial(10, '9', 'Gravel');

      MaterialItem? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await QuickAddMaterialDialog.show(
                    context,
                    onSave: (code, name) async {
                      await Future<void>.delayed(
                        const Duration(milliseconds: 50),
                      );
                      return createdItem;
                    },
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '9');
      await tester.enterText(find.byType(TextFormField).at(1), 'Gravel');
      await tester.tap(find.text('Save Material'));
      await tester.pump(); // Start saving

      // Verify CircularProgressIndicator is shown while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Finish saving and animation

      expect(dialogResult, equals(createdItem));
      expect(
        find.byType(QuickAddMaterialDialog),
        findsNothing,
      ); // Dialog closed
    });

    testWidgets('displays error message and remains open on error', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddMaterialDialog.show(
                  context,
                  onSave: (code, name) async {
                    throw Exception('Material with this code already exists');
                  },
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.enterText(find.byType(TextFormField).at(1), 'Sand');
      await tester.tap(find.text('Save Material'));
      await tester.pumpAndSettle();

      // Verify error banner is displayed
      expect(
        find.text('Material with this code already exists'),
        findsOneWidget,
      );
      // Dialog remains open
      expect(find.byType(QuickAddMaterialDialog), findsOneWidget);
    });
  });
}
