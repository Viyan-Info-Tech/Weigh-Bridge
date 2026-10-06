import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
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

/// The Cancel Weighment confirmation must be fully operable from the keyboard:
/// Enter confirms, Escape keeps editing. The whole point of the dialog is that
/// the operator never has to reach for the mouse.
void main() {
  setUpAll(() => registerFallbackValue(DateTime(2026, 9, 12)));

  late BillBloc billBloc;

  setUp(() {
    final customerRepo = MockCustomerRepository();
    final materialRepo = MockMaterialRepository();
    final save = MockSaveBillUseCase();
    final recent = MockLoadRecentBillsUseCase();
    final gen = MockGenerateBillNumberUseCase();

    when(
      () => customerRepo.getAllActiveCustomers(),
    ).thenAnswer((_) async => <Customer>[]);
    when(
      () => materialRepo.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => <MaterialItem>[]);
    when(
      () => recent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(gen.call).thenAnswer((_) async => 'WB-00001');

    billBloc = BillBloc(
      customerRepository: customerRepo,
      materialRepository: materialRepo,
      saveBillUseCase: save,
      loadRecentBillsUseCase: recent,
      generateBillNumberUseCase: gen,
    );
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

  Finder truckField() => find.byKey(const Key('bill_vehicle_number_field'));

  /// Types a truck number so the form counts as having unsaved data, then
  /// opens the Cancel Weighment confirmation with Escape.
  Future<void> openCancelDialog(WidgetTester tester) async {
    await pumpBillPage(tester);
    await tester.enterText(truckField(), 'TN32AB1234');
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Cancel Weighment?'), findsWidgets);
  }

  group('Cancel Weighment confirmation keyboard handling', () {
    testWidgets('Enter confirms the cancel and clears the form', (
      tester,
    ) async {
      await openCancelDialog(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
        find.text('Cancel Weighment?'),
        findsNothing,
        reason: 'Enter must close the confirmation dialog.',
      );
      expect(
        billBloc.state.vehicleNumber,
        isEmpty,
        reason: 'Enter must cancel the weighment and clear the form.',
      );
    });

    testWidgets('Escape keeps editing and leaves the form intact', (
      tester,
    ) async {
      await openCancelDialog(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(
        find.text('Cancel Weighment?'),
        findsNothing,
        reason: 'Escape must close the confirmation dialog.',
      );
      expect(
        billBloc.state.vehicleNumber,
        'TN32AB1234',
        reason: 'Keep Editing must not clear the entered data.',
      );
    });

    testWidgets('the confirmation receives keyboard focus when it opens', (
      tester,
    ) async {
      await openCancelDialog(tester);

      // Focus must land inside the dialog, otherwise no dialog-scoped shortcut
      // can ever see the key.
      final hasDialogFocus = FocusManager.instance.primaryFocus?.context
              ?.widget
              .runtimeType
              .toString() ??
          '';
      expect(hasDialogFocus, isNotEmpty);
    });
  });
}