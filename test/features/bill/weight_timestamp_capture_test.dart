import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form_weight_row.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Weighment(
        id: 0,
        billNumber: '',
        vehicleNumber: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  group('Weighment timestamp mapping', () {
    final t1 = DateTime(2026, 10, 1, 10, 45);
    final t2 = DateTime(2026, 10, 1, 10, 52);

    test('Gross captured first (firstWeightType = GROSS)', () {
      final w = Weighment(
        id: 1,
        billNumber: 'WB-100',
        vehicleNumber: 'TN01AA1111',
        firstWeightKg: 1223,
        firstWeightType: 'GROSS',
        secondWeightKg: 850,
        secondWeightType: 'TARE',
        createdAt: t1,
        updatedAt: t2,
      );

      expect(w.grossWeightKg, 1223);
      expect(w.tareWeightKg, 850);
      expect(w.grossCapturedAt, t1);
      expect(w.tareCapturedAt, t2);
    });

    test('Tare captured first (firstWeightType = TARE)', () {
      final w = Weighment(
        id: 2,
        billNumber: 'WB-101',
        vehicleNumber: 'TN01AA1111',
        firstWeightKg: 850,
        firstWeightType: 'TARE',
        secondWeightKg: 1223,
        secondWeightType: 'GROSS',
        createdAt: t1,
        updatedAt: t2,
      );

      expect(w.grossWeightKg, 1223);
      expect(w.tareWeightKg, 850);
      expect(w.tareCapturedAt, t1);
      expect(w.grossCapturedAt, t2);
    });
  });

  group('BillFormWeightRow & Widget Behavior', () {
    testWidgets('Displays placeholder when date/time is null', (tester) async {
      final controller = TextEditingController(text: '');
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillFormWeightRow(
              controller: controller,
              weightKg: 0,
              weightUnit: 'kg',
              enabled: true,
              date: null,
              time: null,
              focusNode: focusNode,
              isCaptured: false,
              onSelectDate: (_) {},
              onSelectTime: (_) {},
              onWeightChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('--/--/----'), findsOneWidget);
      expect(find.text('--:-- --'), findsOneWidget);
    });

    testWidgets('Displays formatted date and time when captured', (
      tester,
    ) async {
      final controller = TextEditingController(text: '1223');
      final focusNode = FocusNode();
      final captured = DateTime(2026, 10, 1, 10, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillFormWeightRow(
              controller: controller,
              weightKg: 1223,
              weightUnit: 'kg',
              enabled: true,
              date: captured,
              time: TimeOfDay.fromDateTime(captured),
              focusNode: focusNode,
              isCaptured: true,
              onSelectDate: (_) {},
              onSelectTime: (_) {},
              onWeightChanged: (_) {},
            ),
          ),
        ),
      );

      final dateStr = DateFormat('dd/MM/yyyy').format(captured);
      expect(find.text(dateStr), findsOneWidget);
      expect(find.text('10:45 AM'), findsOneWidget);
    });

    testWidgets(
      'Does NOT trigger commit on typing, only on submitted or focus loss',
      (tester) async {
        final controller = TextEditingController();
        final focusNode = FocusNode();
        String? committedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  BillFormWeightRow(
                    controller: controller,
                    weightKg: 0,
                    weightUnit: 'kg',
                    enabled: true,
                    focusNode: focusNode,
                    isCaptured: false,
                    date: null,
                    time: null,
                    onSelectDate: (_) {},
                    onSelectTime: (_) {},
                    onWeightChanged: (_) {},
                    onWeightCommitted: (val) => committedValue = val,
                  ),
                  const TextField(key: Key('other_field')),
                ],
              ),
            ),
          ),
        );

        // Tap to edit
        await tester.tap(find.byType(BillFormWeightRow));
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField).first, '1223');
        await tester.pump();
        // Not yet committed
        expect(committedValue, isNull);

        // Submit via Enter
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(committedValue, '1223');
      },
    );

    testWidgets('Commits on focus loss', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final otherFocusNode = FocusNode();
      String? committedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BillFormWeightRow(
                  controller: controller,
                  weightKg: 0,
                  weightUnit: 'kg',
                  enabled: true,
                  focusNode: focusNode,
                  isCaptured: false,
                  date: null,
                  time: null,
                  onSelectDate: (_) {},
                  onSelectTime: (_) {},
                  onWeightChanged: (_) {},
                  onWeightCommitted: (val) => committedValue = val,
                ),
                TextField(
                  key: const Key('other_field'),
                  focusNode: otherFocusNode,
                ),
              ],
            ),
          ),
        ),
      );

      // Tap into weight box
      await tester.tap(find.byType(BillFormWeightRow));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '850');
      await tester.pump();
      expect(committedValue, isNull);

      // Move focus away to other field
      otherFocusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(committedValue, '850');
    });
  });

  group('BillBloc timestamp capture & immutability', () {
    late BillBloc bloc;
    late MockSaveBillUseCase mockSaveBillUseCase;
    late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
    late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

    setUp(() async {
      mockSaveBillUseCase = MockSaveBillUseCase();
      mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
      mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

      when(
        () => mockGenerateBillNumberUseCase(),
      ).thenAnswer((_) async => 'WB-00001');
      when(
        () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
      ).thenAnswer((_) async => []);

      bloc = BillBloc(
        saveBillUseCase: mockSaveBillUseCase,
        loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
        generateBillNumberUseCase: mockGenerateBillNumberUseCase,
      );

      bloc.add(const LoadBillScreen());
      await pumpEventQueue();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state has no timestamps', () {
      expect(bloc.state.grossCapturedAt, isNull);
      expect(bloc.state.tareCapturedAt, isNull);
    });

    test(
      'GrossWeightCommitted sets timestamp and preserves it on subsequent edit',
      () async {
        // 1. Commit initial gross weight
        bloc.add(const GrossWeightCommitted('1223'));
        await pumpEventQueue();

        expect(bloc.state.grossWeightKg, 1223);
        expect(bloc.state.grossCapturedAt, isNotNull);
        final initialCaptureTime = bloc.state.grossCapturedAt!;

        // 2. Wait a tick and edit weight from 1223 to 1250
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const GrossWeightCommitted('1250'));
        await pumpEventQueue();

        expect(bloc.state.grossWeightKg, 1250);
        expect(
          bloc.state.grossCapturedAt,
          equals(initialCaptureTime),
        ); // Immutable!

        // 3. Clear weight to 0 resets timestamp
        bloc.add(const GrossWeightCommitted(''));
        await pumpEventQueue();

        expect(bloc.state.grossWeightKg, 0);
        expect(bloc.state.grossCapturedAt, isNull);
      },
    );

    test(
      'TareWeightCommitted sets timestamp and preserves it on subsequent edit',
      () async {
        // 1. Commit initial tare weight
        bloc.add(const TareWeightCommitted('850'));
        await pumpEventQueue();

        expect(bloc.state.tareWeightKg, 850);
        expect(bloc.state.tareCapturedAt, isNotNull);
        final initialCaptureTime = bloc.state.tareCapturedAt!;

        // 2. Wait a tick and edit tare from 850 to 900
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const TareWeightCommitted('900'));
        await pumpEventQueue();

        expect(bloc.state.tareWeightKg, 900);
        expect(
          bloc.state.tareCapturedAt,
          equals(initialCaptureTime),
        ); // Immutable!

        // 3. Clear tare resets timestamp
        bloc.add(const TareWeightCommitted('0'));
        await pumpEventQueue();

        expect(bloc.state.tareWeightKg, 0);
        expect(bloc.state.tareCapturedAt, isNull);
      },
    );

    test(
      'Scale live weight capture sets weight and timestamp together',
      () async {
        bloc.add(
          const LiveScaleWeightUpdated(
            weightKg: 2500,
            isStable: true,
            isMotion: false,
            isOverload: false,
          ),
        );
        await pumpEventQueue();

        bloc.add(const CaptureLiveWeight(type: 'Gross'));
        await pumpEventQueue();

        expect(bloc.state.grossWeightKg, 2500);
        expect(bloc.state.grossCapturedAt, isNotNull);
      },
    );

    test(
      'SaveAndPrintBillRequested forwards captured timestamps to saved weighment and printReceiptBill',
      () async {
        final grossTime = DateTime(2026, 10, 14, 14, 11);
        final tareTime = DateTime(2026, 10, 14, 14, 15);

        Weighment? passedWeighment;
        when(() => mockSaveBillUseCase.withNewBillNumber(any())).thenAnswer((
          inv,
        ) async {
          passedWeighment = inv.positionalArguments[0] as Weighment;
          return (id: 42, billNumber: 'WB-00042');
        });

        bloc.add(const VehicleNumberChanged('TN01AA1111'));
        bloc.add(GrossWeightCommitted('45000', capturedAt: grossTime));
        bloc.add(TareWeightCommitted('15000', capturedAt: tareTime));
        await pumpEventQueue();

        bloc.add(const SaveAndPrintBillRequested());
        await pumpEventQueue();

        expect(passedWeighment, isNotNull);
        expect(passedWeighment!.grossCapturedAt, grossTime);
        expect(passedWeighment!.tareCapturedAt, tareTime);
        expect(bloc.state.printReceiptBill, isNotNull);
        expect(bloc.state.printReceiptBill!.grossCapturedAt, grossTime);
        expect(bloc.state.printReceiptBill!.tareCapturedAt, tareTime);
      },
    );
  });
}
