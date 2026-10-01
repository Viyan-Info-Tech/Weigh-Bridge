import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
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

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 10, 1));
  });

  late BillBloc billBloc;
  late MockCustomerRepository mockCustomerRepo;
  late MockMaterialRepository mockMaterialRepo;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  final testCustomer = Customer(
    id: 1,
    customerCode: 'C-001',
    name: 'UltraTech Cement',
    mobile: '9876543210',
    isActive: true,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final testMaterial = MaterialItem(
    id: 1,
    code: 'M-001',
    name: 'Sand',
    isActive: true,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUp(() {
    mockCustomerRepo = MockCustomerRepository();
    mockMaterialRepo = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(
      () => mockCustomerRepo.getAllActiveCustomers(),
    ).thenAnswer((_) => Future.value([testCustomer]));
    when(
      () => mockCustomerRepo.getCustomerByCode(any()),
    ).thenAnswer((_) => Future.value(testCustomer));
    when(
      () => mockMaterialRepo.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) => Future.value([testMaterial]));
    when(
      () => mockMaterialRepo.getMaterialByCode(any()),
    ).thenAnswer((_) => Future.value(testMaterial));
    when(
      () => mockLoadRecentBillsUseCase(),
    ).thenAnswer((_) => Future.value([]));
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value([]));
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00001'));

    billBloc = BillBloc(
      customerRepository: mockCustomerRepo,
      materialRepository: mockMaterialRepo,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() {
    billBloc.close();
  });

  Future<void> pumpTestBillPage(
    WidgetTester tester, {
    VoidCallback? onExit,
    bool isActive = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: billBloc,
          child: BillPage(isActive: isActive, onExit: onExit),
        ),
      ),
    );
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere(
        (s) => s.status == BillScreenStatus.loaded,
      );
    });
    await tester.pumpAndSettle();
  }

  group('Weighment Global Keyboard Shortcuts Tests', () {
    testWidgets('Ctrl + S validates and shows field errors when form is empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpTestBillPage(tester);
      // ignore: avoid_print
      print('STATUS: ${billBloc.state.status}');

      // ignore: avoid_print
      print('TEST: BEFORE CTRL+S');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      // ignore: avoid_print
      print('TEST: AFTER KEYS SENT');
      await tester.pump();
      // ignore: avoid_print
      print('TEST: AFTER PUMP 1');
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print('TEST: AFTER PUMPANDSETTLE');
      await tester.pump();
      // ignore: avoid_print
      print('TEST: AFTER PUMP 2');
      // ignore: avoid_print
      print(
        'TEST: BEFORE EXPECT, state.vehicleNumberError = ${billBloc.state.vehicleNumberError}',
      );

      // Expect field errors to appear
      expect(find.text('Truck number is required.'), findsOneWidget);
      expect(find.text('Material code is required.'), findsOneWidget);
      expect(find.text('Customer code is required.'), findsOneWidget);
    });

    testWidgets(
      'Esc when unsaved data exists triggers cancel confirmation dialog',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await pumpTestBillPage(tester);

        // Enter vehicle number
        await tester.enterText(
          find.byKey(const Key('bill_vehicle_number_field')),
          'TN32AB1234',
        );
        await tester.pumpAndSettle();

        // Press Esc
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('Cancel Weighment?'), findsOneWidget);
      },
    );

    testWidgets(
      'Esc when a modal dialog is open closes dialog without cancelling ticket',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await pumpTestBillPage(tester);

        // Enter vehicle number so unsaved data exists
        await tester.enterText(
          find.byKey(const Key('bill_vehicle_number_field')),
          'TN32AB1234',
        );
        await tester.pumpAndSettle();

        // Open a custom modal dialog
        showDialog(
          context: tester.element(find.byType(Scaffold)),
          builder: (ctx) => const AlertDialog(title: Text('Test Modal Dialog')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Test Modal Dialog'), findsOneWidget);

        // Press Esc: this should dismiss the test modal dialog ONLY
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        // Modal dialog should be dismissed
        expect(find.text('Test Modal Dialog'), findsNothing);
        // 'Cancel Weighment?' should NOT have been opened
        expect(find.text('Cancel Weighment?'), findsNothing);
        // The vehicle number should still be intact
        expect(find.text('TN32AB1234'), findsOneWidget);
      },
    );

    testWidgets(
      'action bar shows REGISTER WEIGHT with F1 badge and it runs the F1 workflow',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await pumpTestBillPage(tester);

        expect(find.text('REGISTER WEIGHT'), findsOneWidget);

        await tester.tap(find.text('REGISTER WEIGHT'));
        await tester.pumpAndSettle();

        // F1 workflow validates the truck number before capturing any weight.
        expect(
          find.text('Truck number must be exactly 10 characters.'),
          findsOneWidget,
        );
        expect(find.text('SAVE'), findsOneWidget);
        expect(find.text('CANCEL'), findsOneWidget);
        expect(find.text('MANUAL TARE'), findsOneWidget);
        expect(find.text('AUTO TARE'), findsNWidgets(2));
        expect(find.text('RE-PRINT'), findsOneWidget);
      },
    );

    testWidgets('F9 invokes onExit callback', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool exitCalled = false;
      await pumpTestBillPage(
        tester,
        onExit: () {
          exitCalled = true;
        },
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f9);
      await tester.pumpAndSettle();

      expect(exitCalled, isTrue);
    });
  });
}
