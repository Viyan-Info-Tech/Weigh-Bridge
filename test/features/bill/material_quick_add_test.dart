import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/widgets/quick_add_material_dialog.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/party/domain/repositories/party_repository.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockVehicleTypeRepository extends Mock implements VehicleTypeRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class MockLoadPendingBillsUseCase extends Mock
    implements LoadPendingBillsUseCase {}

void main() {
  late BillBloc billBloc;
  late MockPartyRepository mockPartyRepository;
  late MockVehicleRepository mockVehicleRepository;
  late MockVehicleTypeRepository mockVehicleTypeRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;
  late MockLoadPendingBillsUseCase mockLoadPendingBillsUseCase;

  setUp(() {
    mockPartyRepository = MockPartyRepository();
    mockVehicleRepository = MockVehicleRepository();
    mockVehicleTypeRepository = MockVehicleTypeRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();
    mockLoadPendingBillsUseCase = MockLoadPendingBillsUseCase();

    billBloc = BillBloc(
      partyRepository: mockPartyRepository,
      vehicleRepository: mockVehicleRepository,
      vehicleTypeRepository: mockVehicleTypeRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      loadPendingBillsUseCase: mockLoadPendingBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() {
    billBloc.close();
  });

  group('Material Quick Add - BillBloc', () {
    test(
      'successfully creates material, updates state.materials and selectedMaterial',
      () async {
        final existingMaterials = [
          MaterialItem(
            id: 1,
            name: 'Sand',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final createdMaterial = MaterialItem(
          id: 2,
          name: 'Stone',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => mockMaterialRepository.getAllMaterials(),
        ).thenAnswer((_) async => existingMaterials);
        when(
          () => mockMaterialRepository.createMaterial(
            name: 'Stone',
            category: '',
          ),
        ).thenAnswer((_) async => 2);
        when(
          () => mockMaterialRepository.getMaterialById(2),
        ).thenAnswer((_) async => createdMaterial);

        final result = await billBloc.quickAddMaterial('Stone');

        expect(result, equals(createdMaterial));
        expect(billBloc.state.materials.any((m) => m.name == 'Stone'), isTrue);
        expect(billBloc.state.selectedMaterial, equals(createdMaterial));
        expect(billBloc.state.errorMessage, isNull);
      },
    );

    test('prevents case-insensitive duplicate materials', () async {
      final existingMaterials = [
        MaterialItem(
          id: 1,
          name: 'Stone',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        () => mockMaterialRepository.getAllMaterials(),
      ).thenAnswer((_) async => existingMaterials);

      expect(
        () => billBloc.quickAddMaterial('stone'),
        throwsA(isA<Exception>()),
      );

      // Wait a microtask for state emission
      await Future<void>.delayed(Duration.zero);
      expect(billBloc.state.errorMessage, contains('already exists'));
    });

    test('prevents empty material name', () async {
      expect(() => billBloc.quickAddMaterial('   '), throwsA(isA<Exception>()));

      await Future<void>.delayed(Duration.zero);
      expect(
        billBloc.state.errorMessage,
        contains('Material name is required'),
      );
    });
  });

  group('QuickAddMaterialDialog Widget Tests', () {
    testWidgets('renders dialog and validates empty name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddMaterialDialog.show(
                  context,
                  onSave: (name) async => null,
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
      expect(find.text('Material Name *'), findsOneWidget);

      // Try to save empty
      await tester.tap(find.text('Save Material'));
      await tester.pumpAndSettle();

      expect(find.text('Material name is required'), findsOneWidget);
    });

    testWidgets('shows loading and returns created material on success', (
      tester,
    ) async {
      final createdItem = MaterialItem(
        id: 10,
        name: 'Gravel',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      MaterialItem? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await QuickAddMaterialDialog.show(
                    context,
                    onSave: (name) async {
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

      await tester.enterText(find.byType(TextFormField), 'Gravel');
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
                  onSave: (name) async {
                    throw Exception('Material with this name already exists');
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

      await tester.enterText(find.byType(TextFormField), 'Sand');
      await tester.tap(find.text('Save Material'));
      await tester.pumpAndSettle();

      // Verify error banner is displayed
      expect(
        find.text('Material with this name already exists'),
        findsOneWidget,
      );
      // Dialog remains open
      expect(find.byType(QuickAddMaterialDialog), findsOneWidget);
    });
  });
}
