import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

/// The Charges field is typed by the operator only: the bloc stores the text,
/// validates it on save, and persists the parsed amount exactly as entered.
/// Nothing here recalculates charges from weights, material or the vehicle.
void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;
  late BillBloc bloc;

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
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00002');
    when(() => mockSaveBill.withNewBillNumber(any())).thenAnswer(
      (inv) async => (id: 2, billNumber: 'WB-00002'),
    );

    bloc = BillBloc(
      saveBillUseCase: mockSaveBill,
      loadRecentBillsUseCase: mockLoadRecent,
      generateBillNumberUseCase: mockGenerateBillNumber,
    );
  });

  tearDown(() => bloc.close());

  Future<void> loadLoadedScreen() async {
    bloc.add(const LoadBillScreen());
    await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);
  }

  /// Fills the form with a valid weighment so a save can succeed.
  Future<void> fillValidForm() async {
    bloc.add(const VehicleNumberChanged('TN09AB1234'));
    bloc.add(const GrossWeightCommitted('10000', capturedAt: null));
    await bloc.stream.firstWhere((s) => s.grossWeightKg == 10000);
  }

  group('ChargesChanged', () {
    test('stores the typed text verbatim', () async {
      await loadLoadedScreen();

      bloc.add(const ChargesChanged('250'));
      await bloc.stream.firstWhere((s) => s.chargesText == '250');
      expect(bloc.state.chargesText, '250');

      bloc.add(const ChargesChanged('250.'));
      await bloc.stream.firstWhere((s) => s.chargesText == '250.');
      expect(bloc.state.chargesText, '250.');
    });

    test('clears a stale charges error once the text is valid again', () async {
      await loadLoadedScreen();

      bloc.add(const ChargesChanged('abc'));
      await bloc.stream.firstWhere((s) => s.chargesText == 'abc');
      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.chargesError != null);
      expect(bloc.state.chargesError, isNotNull);

      bloc.add(const ChargesChanged('120'));
      await bloc.stream.firstWhere((s) => s.chargesText == '120');
      expect(bloc.state.chargesError, isNull);
    });
  });

  group('charges validation on save', () {
    test('rejects non-numeric input', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('abc'));
      await bloc.stream.firstWhere((s) => s.chargesText == 'abc');

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.chargesError != null);

      expect(bloc.state.chargesError, isNotNull);
      verifyNever(() => mockSaveBill.withNewBillNumber(any()));
    });

    test('rejects more than two decimal places', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('250.555'));
      await bloc.stream.firstWhere((s) => s.chargesText == '250.555');

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.chargesError != null);
      verifyNever(() => mockSaveBill.withNewBillNumber(any()));
    });

    test('rejects a negative amount', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('-100'));
      await bloc.stream.firstWhere((s) => s.chargesText == '-100');

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.chargesError != null);
      verifyNever(() => mockSaveBill.withNewBillNumber(any()));
    });

    test('accepts an empty field (no charge)', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.saved);

      final captured = verify(
        () => mockSaveBill.withNewBillNumber(captureAny()),
      ).captured.single;
      expect(captured.charges, isNull);
    });

    test('accepts zero and stores it as 0', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('0'));
      await bloc.stream.firstWhere((s) => s.chargesText == '0');

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.saved);

      final captured = verify(
        () => mockSaveBill.withNewBillNumber(captureAny()),
      ).captured.single;
      expect(captured.charges, 0);
    });
  });

  group('charges persistence', () {
    test('saves the entered amount exactly (no recalculation)', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('250.50'));
      await bloc.stream.firstWhere((s) => s.chargesText == '250.50');

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.saved);

      final captured = verify(
        () => mockSaveBill.withNewBillNumber(captureAny()),
      ).captured.single;
      expect(captured.charges, 250.50);
    });

    test('a thousand-rupee charge survives save and print', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('1000.00'));
      await bloc.stream.firstWhere((s) => s.chargesText == '1000.00');

      bloc.add(const SaveAndPrintBillRequested());
      await bloc.stream.firstWhere(
        (s) => s.status == BillScreenStatus.printing &&
            s.printReceiptBill != null,
      );

      expect(bloc.state.printReceiptBill!.charges, 1000);
    });
  });

  group('form reset', () {
    test('ClearBillRequested clears the charges text', () async {
      await loadLoadedScreen();

      bloc.add(const ChargesChanged('500'));
      await bloc.stream.firstWhere((s) => s.chargesText == '500');

      bloc.add(const ClearBillRequested());
      await bloc.stream.firstWhere((s) => s.chargesText.isEmpty);
      expect(bloc.state.chargesText, isEmpty);
    });

    test('a successful save resets the charges field', () async {
      await loadLoadedScreen();
      await fillValidForm();

      bloc.add(const ChargesChanged('750'));
      await bloc.stream.firstWhere((s) => s.chargesText == '750');

      bloc.add(const SaveBillRequested());
      await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.saved);
      expect(bloc.state.chargesText, isEmpty);
    });
  });
}
