import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

/// A successful save must leave a clean New Bill form behind the receipt.
///
/// The bill itself was correct while the form behind the preview was showing
/// validation errors from `_validateAll`, so the form was
/// being validated *after* it had already been reset. One Ctrl+S dispatches
/// `SaveAndPrintBillRequested` twice, because `BillPage` registers both a raw
/// `HardwareKeyboard` handler and a `Shortcuts` widget and the two key systems
/// are independent. The first event saved and reset the form; the second then
/// validated the empty form.
void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;
  late BillBloc bloc;

  var nextBillNumber = 2;

  setUpAll(() {
    registerFallbackValue(
      Weighment(
        id: 0,
        billNumber: 'WB-00000',
        vehicleNumber: 'TN09AB1234',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    nextBillNumber = 2;
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-0000$nextBillNumber');
    when(() => mockSaveBill.withNewBillNumber(any())).thenAnswer((inv) async {
      nextBillNumber++;
      return (id: nextBillNumber, billNumber: 'WB-0000$nextBillNumber');
    });

    bloc = BillBloc(
      saveBillUseCase: mockSaveBill,
      loadRecentBillsUseCase: mockLoadRecent,
      generateBillNumberUseCase: mockGenerateBillNumber,
    );
  });

  tearDown(() => bloc.close());

  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  /// Drives the same events the operator's keystrokes produce.
  Future<void> fillValidTareBill({String truck = 'TN09AB1234'}) async {
    bloc.add(const LoadBillScreen());
    await settle();
    bloc.add(VehicleNumberChanged(truck));
    bloc.add(const TareWeightCommitted('2000'));
    await settle();
  }

  test('a single save leaves a clean form behind the receipt', () async {
    await fillValidTareBill();
    expect(bloc.state.hasFieldErrors, isFalse, reason: 'precondition');

    bloc.add(const SaveAndPrintBillRequested());
    await settle();

    expect(bloc.state.printReceiptBill, isNotNull, reason: 'the save ran');
    expect(bloc.state.hasFieldErrors, isFalse);
    expect(bloc.state.errorMessage, isNull);
    expect(bloc.state.vehicleNumber, isEmpty);
    expect(bloc.state.tareWeightKg, 0);
  });

  test(
    'the duplicate half of one Ctrl+S does not validate the reset form',
    () async {
      await fillValidTareBill();

      // Exactly what a single Ctrl+S produces today: two queued events.
      bloc.add(const SaveAndPrintBillRequested());
      bloc.add(const SaveAndPrintBillRequested());
      await settle();

      expect(bloc.state.printReceiptBill, isNotNull, reason: 'the save ran');
      expect(
        bloc.state.hasFieldErrors,
        isFalse,
        reason: 'the reset form must not be validated behind the preview',
      );
      verify(() => mockSaveBill.withNewBillNumber(any())).called(1);
    },
  );

  test(
    'holds when the receipt is dismissed before the duplicate is handled',
    () async {
      await fillValidTareBill();

      // `BillPage` dispatches PrintReceiptDismissed the moment the preview
      // opens (bill_page.dart). The two key systems can fire in separate
      // event-loop turns, so the duplicate can arrive *after* that dismissal,
      // which defeats any check based on the receipt still being open.
      var subscription = bloc.stream.listen((s) {
        if (s.printReceiptBill != null && !s.hasFieldErrors) {
          bloc.add(const PrintReceiptDismissed());
        }
      });
      addTearDown(subscription.cancel);

      bloc.add(const SaveAndPrintBillRequested());
      // Deliberately in a later turn, so the dismissal lands in between.
      await settle();
      bloc.add(const SaveAndPrintBillRequested());
      await settle();

      expect(
        bloc.state.hasFieldErrors,
        isFalse,
        reason: 'the guard must not depend on the receipt still being open',
      );
      verify(() => mockSaveBill.withNewBillNumber(any())).called(1);
    },
  );

  test(
    'the next bill can still be saved after the receipt is dismissed',
    () async {
      await fillValidTareBill();
      bloc.add(const SaveAndPrintBillRequested());
      await settle();
      expect(bloc.state.printReceiptBill, isNotNull);

      bloc.add(const PrintReceiptDismissed());
      await settle();
      expect(bloc.state.printReceiptBill, isNull);

      // A fresh, valid second bill must not be swallowed by the guard.
      await fillValidTareBill(truck: 'TN09AB5678');
      bloc.add(const SaveAndPrintBillRequested());
      await settle();

      expect(bloc.state.printReceiptBill, isNotNull);
      expect(bloc.state.hasFieldErrors, isFalse);
      verify(() => mockSaveBill.withNewBillNumber(any())).called(2);
    },
  );

  test('a genuinely invalid form still reports its errors', () async {
    bloc.add(const LoadBillScreen());
    await settle();

    bloc.add(const SaveAndPrintBillRequested());
    await settle();

    expect(bloc.state.hasFieldErrors, isTrue);
    expect(bloc.state.vehicleNumberError, 'Truck number is required.');
    expect(bloc.state.weightError, isNotNull);
    verifyNever(() => mockSaveBill.withNewBillNumber(any()));
  });
}
