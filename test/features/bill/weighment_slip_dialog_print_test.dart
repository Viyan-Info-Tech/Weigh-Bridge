import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/app/app.dart' show scaffoldMessengerKey;
import 'package:weighbridge/core/printing/print_service.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weighment_slip_dialog.dart';

class MockPrintService extends Mock implements PrintService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  late MockPrintService printService;
  late Weighment bill;

  setUp(() {
    printService = MockPrintService();
    final now = DateTime(2026, 9, 10, 16, 27);
    bill = Weighment(
      id: 1,
      billNumber: 'WB-00001',
      vehicleNumber: 'TN31CM2026',
      customerId: 20,
      materialId: 30,
      grossWeightKg: 100000.0,
      tareWeightKg: 20000.0,
      netWeightKg: 80000.0,
      createdAt: now,
      updatedAt: now,
    );
  });

  Widget buildHost() {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => WeighmentSlipDialog(
                  bill: bill,
                  materialName: 'Sand',
                  printService: printService,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(buildHost());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Print Ticket'), findsOneWidget);
  }

  group('WeighmentSlipDialog Print Ticket', () {
    testWidgets('prints the generated PDF and closes the dialog on success', (
      tester,
    ) async {
      when(
        () => printService.printPdf(any(), jobName: any(named: 'jobName')),
      ).thenAnswer((_) async => true);

      await openDialog(tester);
      await tester.tap(find.text('Print Ticket'));
      await tester.pumpAndSettle();

      // Dialog closed after a successful print.
      expect(find.text('Print Ticket'), findsNothing);

      final captured = verify(
        () => printService.printPdf(
          captureAny(),
          jobName: captureAny(named: 'jobName'),
        ),
      ).captured;
      final pdfBytes = captured[0] as Uint8List;
      final jobName = captured[1] as String;
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]); // %PDF
      expect(jobName, contains('WB-00001'));

      expect(
        find.textContaining('Print job sent for WB-00001'),
        findsOneWidget,
      );
    });

    testWidgets(
      'keeps the dialog open and shows an error when printing fails',
      (tester) async {
        when(
          () => printService.printPdf(any(), jobName: any(named: 'jobName')),
        ).thenAnswer((_) async => false);

        await openDialog(tester);
        await tester.tap(find.text('Print Ticket'));
        await tester.pumpAndSettle();

        // Dialog must stay open so the user can retry.
        expect(find.text('Print Ticket'), findsOneWidget);
        expect(
          find.textContaining('Unable to print ticket for WB-00001'),
          findsOneWidget,
        );
      },
    );

    testWidgets('keeps the dialog open when the print pipeline throws', (
      tester,
    ) async {
      when(
        () => printService.printPdf(any(), jobName: any(named: 'jobName')),
      ).thenThrow(Exception('printer exploded'));

      await openDialog(tester);
      await tester.tap(find.text('Print Ticket'));
      await tester.pumpAndSettle();

      expect(find.text('Print Ticket'), findsOneWidget);
      expect(find.textContaining('Failed to print ticket'), findsOneWidget);
    });

    testWidgets('disables the button and shows progress while printing', (
      tester,
    ) async {
      final completer = Completer<bool>();
      when(
        () => printService.printPdf(any(), jobName: any(named: 'jobName')),
      ).thenAnswer((_) => completer.future);

      await openDialog(tester);
      await tester.tap(find.text('Print Ticket'));
      await tester.pump();

      // Button switches to a spinner while the job is in flight.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Print Ticket'), findsNothing);

      completer.complete(true);
      await tester.pumpAndSettle();

      expect(find.text('Print Ticket'), findsNothing);
      expect(
        find.textContaining('Print job sent for WB-00001'),
        findsOneWidget,
      );
    });

    testWidgets('Close button still works and does not print', (tester) async {
      await openDialog(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Print Ticket'), findsNothing);
      verifyNever(
        () => printService.printPdf(any(), jobName: any(named: 'jobName')),
      );
    });
  });
}
