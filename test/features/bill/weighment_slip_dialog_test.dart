import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weighment_slip_dialog.dart';

void main() {
  group('WeighmentSlipDialog Widget Tests', () {
    late Weighment testBill;

    setUp(() {
      final now = DateTime(2026, 9, 10, 16, 27);
      testBill = Weighment(
        id: 1,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        grossWeightKg: 100000.0,
        tareWeightKg: 20000.0,
        netWeightKg: 80000.0,
        remarks: 'Direct delivery to site',
        createdAt: now,
        updatedAt: now,
      );
    });

    void setScreenSize(WidgetTester tester, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Future<void> pumpDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WeighmentSlipDialog(bill: testBill)),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders exactly one ticket from the record', (tester) async {
      setScreenSize(tester, const Size(1200, 900));
      await pumpDialog(tester);

      // 1. Letterhead and title, shown once - the preview has no duplicate.
      expect(find.text('VIYAN WEIGHBRIDGE'), findsOneWidget);
      expect(find.text('Computer Weigh Bridge'), findsOneWidget);
      expect(find.text('24 HOURS SERVICE'), findsOneWidget);
      expect(find.text('WEIGHMENT RECEIPT'), findsOneWidget);

      // 2. Every field of the physical ticket, on the single receipt.
      for (final label in const [
        'SERIAL NO.',
        'DATE',
        'TIME',
        'VEHICLE NO.',
        'WT. CHARGES (Rs.)',
        'MATERIAL',
        'GROSS',
        'TARE',
        'Nett',
        'CUSTOMER',
      ]) {
        expect(
          find.text(label),
          findsOneWidget,
          reason: 'label "$label" should appear once',
        );
      }

      // 3. Values resolved from the selected weighment record - never
      //    hardcoded.
      for (final value in const [
        'WB-00001',
        'TN31CM2026',
        '10/09/2026',
        '04:27 PM',
        '100.000 ton',
        '20.000 ton',
        '80.000 ton',
      ]) {
        expect(
          find.text(value),
          findsOneWidget,
          reason: 'value "$value" should appear once',
        );
      }

      // 4. Modal actions.
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Print Ticket'), findsOneWidget);
    });

    testWidgets('keeps the preview usable in a narrow window', (tester) async {
      // Below the readable scale the receipt scrolls horizontally instead of
      // overflowing, so it stays inspectable.
      setScreenSize(tester, const Size(600, 700));
      await pumpDialog(tester);

      expect(find.text('WB-00001'), findsOneWidget);
      expect(find.text('100.000 ton'), findsOneWidget);
      expect(find.text('Print Ticket'), findsOneWidget);
    });

    testWidgets('clicking Close closes the dialog', (tester) async {
      setScreenSize(tester, const Size(1200, 900));
      await pumpDialog(tester);

      // The business name shows once, in the ticket letterhead.
      expect(find.text('VIYAN WEIGHBRIDGE'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('VIYAN WEIGHBRIDGE'), findsNothing);
    });
  });
}
