import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/repositories/auto_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

/// A tare-only weighment has no net weight and so no material to price
/// against. Material Code must therefore be skipped by the keyboard focus
/// order when TARE is selected, while GROSS keeps the normal order.
void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 12));
  });

  late BillBloc billBloc;
  late MockCustomerRepository mockCustomerRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  final testCustomers = [
    Customer(
      id: 1,
      customerCode: 'C-001',
      name: 'UltraTech Cement',
      mobile: '9876543210',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testMaterials = [
    MaterialItem(
      id: 1,
      code: '1',
      name: 'Sand',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  setUp(() {
    mockCustomerRepository = MockCustomerRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(
      () => mockCustomerRepository.getAllActiveCustomers(),
    ).thenAnswer((_) async => testCustomers);
    when(
      () => mockMaterialRepository.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => testMaterials);
    when(
      () => mockLoadRecentBillsUseCase.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(
      () => mockGenerateBillNumberUseCase.call(),
    ).thenAnswer((_) async => 'WB-00001');

    billBloc = BillBloc(
      customerRepository: mockCustomerRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
      autoTareRepository: null,
    ) as BillBloc;
  });

  Future<void> pumpBillPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: billBloc, child: const BillPage()),
      ),
    );
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere(
        (s) => s.status == BillScreenStatus.loaded,
      );
    });
    await tester.pumpAndSettle();
  }

  Finder materialField() => find.byKey(const Key('bill_material_code_field'));
  Finder customerField() => find.byKey(const Key('bill_customer_code_field'));
  Finder truckField() => find.byKey(const Key('bill_vehicle_number_field'));

  /// Selects GROSS or TARE on the toggle.
  Future<void> selectType(WidgetTester tester, String type) async {
    billBloc.add(WeightTypeSelected(type));
    await tester.pumpAndSettle();
  }

  group('Material Code is skipped for a tare-only weighment', () {
    /// Drives Enter from the truck field onto the type selector and off it
    /// again, mirroring how the operator reaches the next field.
    Future<void> pressEnterTwiceFromTruck(WidgetTester tester) async {
      await tester.tap(truckField());
      await tester.pumpAndSettle();
      // Truck -> GROSS/TARE selector.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      // Selector -> next field.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
    }

    FocusNode focusOf(WidgetTester tester, Finder finder) =>
        tester.widget<TextField>(finder).focusNode!;

    testWidgets('GROSS: Enter on the type selector lands on Material Code', (
      tester,
    ) async {
      await pumpBillPage(tester);
      await selectType(tester, 'Gross');

      await pressEnterTwiceFromTruck(tester);

      expect(
        focusOf(tester, materialField()).hasFocus,
        isTrue,
        reason: 'A gross weighment must stop on Material Code.',
      );
    });

    testWidgets('TARE: Enter on the type selector skips to Customer Code', (
      tester,
    ) async {
      await pumpBillPage(tester);
      await selectType(tester, 'Tare');

      await pressEnterTwiceFromTruck(tester);

      expect(
        focusOf(tester, materialField()).hasFocus,
        isFalse,
        reason: 'Material Code must not receive focus for a tare weighment.',
      );
      expect(
        focusOf(tester, customerField()).hasFocus,
        isTrue,
        reason: 'Focus must land on Customer Code instead.',
      );
    });

    testWidgets('TARE: Enter inside Material Code steps on, no error', (
      tester,
    ) async {
      await pumpBillPage(tester);
      await selectType(tester, 'Tare');

      // Reach Material Code directly, as if the operator clicked it.
      await tester.tap(materialField());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(focusOf(tester, customerField()).hasFocus, isTrue);
      expect(
        find.text('Material code is required.'),
        findsNothing,
        reason: 'A tare-only weighment must not be blocked by a material error.',
      );
    });

    testWidgets('TARE: Tab order does not stop on Material Code', (
      tester,
    ) async {
      await pumpBillPage(tester);
      await selectType(tester, 'Tare');

      final materialFocus = focusOf(tester, materialField());
      final customerFocus = focusOf(tester, customerField());

      await tester.tap(truckField());
      await tester.pumpAndSettle();

      final visited = <String>[];
      for (var i = 0; i < 6; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        if (materialFocus.hasFocus) visited.add('material');
        if (customerFocus.hasFocus) visited.add('customer');
      }

      expect(
        visited,
        isNot(contains('material')),
        reason: 'Tab must not land on Material Code for a tare weighment.',
      );
      expect(
        visited,
        contains('customer'),
        reason: 'Tab must still reach Customer Code.',
      );
    });
  });
}