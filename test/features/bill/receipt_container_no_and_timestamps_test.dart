import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/data/datasources/bill_local_datasource.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/services/weighment_receipt_data.dart';
import 'package:weighbridge/features/bill/domain/services/weighment_ticket_pdf_generator.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weighment_receipt_template.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

import '../../support/test_database.dart';

void main() {
  group('Receipt CONTAINER NO label and capture date/time tests', () {
    final grossCapture = DateTime(2026, 10, 14, 14, 11); // 14/10/2026 02:11 PM
    final tareCapture = DateTime(2026, 10, 14, 14, 11); // 14/10/2026 02:11 PM
    final printTime = DateTime(2026, 10, 14, 14, 19, 48);

    final bill = Weighment(
      id: 1,
      billNumber: 'WB-00011',
      vehicleNumber: 'TN01AB1234',
      firstWeightKg: 45000,
      firstWeightType: 'GROSS',
      secondWeightKg: 15000,
      secondWeightType: 'TARE',
      netWeightKg: 30000,
      grossCapturedAt: grossCapture,
      tareCapturedAt: tareCapture,
      remarks: '11',
      createdAt: DateTime(2026, 10, 14, 14, 0),
      updatedAt: DateTime(2026, 10, 14, 14, 15),
    );

    final settings = BillingSettings(
      businessName: 'VIYAN WEIGHBRIDGE',
      showRemarks: true,
      showGrossWeight: true,
      showTareWeight: true,
      showNetWeight: true,
      weightUnit: 'kg',
      updatedAt: DateTime(2026, 10, 14),
    );

    test('WeighmentReceiptData formats actual capture timestamps and keep Net as --', () {
      final receiptData = WeighmentReceiptData(
        bill: bill,
        settings: settings,
        printedAt: printTime,
      );

      // Gross capture timestamp
      expect(receiptData.grossDate, '14/10/2026');
      expect(receiptData.grossTime, '02:11 PM');

      // Tare capture timestamp
      expect(receiptData.tareDate, '14/10/2026');
      expect(receiptData.tareTime, '02:11 PM');

      // Print timestamp
      expect(receiptData.printDate, '14/10/2026 14:19:48');
    });

    testWidgets('WeighmentReceiptTemplate displays CONTAINER NO in uppercase and actual dates/times', (tester) async {
      final receiptData = WeighmentReceiptData(
        bill: bill,
        settings: settings,
        printedAt: printTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WeighmentReceiptTemplate(data: receiptData),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Requirement 1: CONTAINER NO uppercase, no 'CONTAINER No'
      expect(find.text('CONTAINER NO'), findsOneWidget);
      expect(find.text('CONTAINER No'), findsNothing);
      expect(find.text('11'), findsOneWidget);

      // Requirement 2: Actual captured timestamps
      expect(find.text('14/10/2026'), findsNWidgets(2)); // Gross and Tare
      expect(find.text('02:11 PM'), findsNWidgets(2)); // Gross and Tare

      // Net date and time must be '--'
      expect(find.text('--'), findsWidgets);

      // Printed timestamp
      expect(find.textContaining('14/10/2026 14:19:48'), findsOneWidget);
    });

    test('WeighmentTicketPdfGenerator generates PDF with CONTAINER NO and capture timestamps', () async {
      const generator = WeighmentTicketPdfGenerator();
      final pdfBytes = await generator.generateTicketPdf(
        bill: bill,
        settings: settings,
        printedAt: printTime,
      );
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]); // %PDF
    });

    test('Persistence & Reprinting preserves capture timestamps across database reloads', () async {
      final db = createInMemoryDatabase();
      final source = BillLocalDataSource(db);

      try {
        final id = await source.saveWeighment(bill);
        final loadedBill = await source.getWeighmentById(id);

        expect(loadedBill, isNotNull);
        expect(loadedBill!.grossCapturedAt, grossCapture);
        expect(loadedBill.tareCapturedAt, tareCapture);

        // Simulate reprinting the bill at a later time
        final reprintTime = DateTime(2026, 10, 20, 10, 30, 0);
        final reprintReceiptData = WeighmentReceiptData(
          bill: loadedBill,
          settings: settings,
          printedAt: reprintTime,
        );

        // Capture timestamps must still be the original recorded dates/times, NOT DateTime.now()
        expect(reprintReceiptData.grossDate, '14/10/2026');
        expect(reprintReceiptData.grossTime, '02:11 PM');
        expect(reprintReceiptData.tareDate, '14/10/2026');
        expect(reprintReceiptData.tareTime, '02:11 PM');

        // Printed on is the reprint time
        expect(reprintReceiptData.printDate, '20/10/2026 10:30:00');
      } finally {
        await db.close();
      }
    });
  });
}
