import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weighment_slip_dialog.dart';

void main() {
  group('WeighmentSlipDialog Widget Tests', () {
    late Weighment testBill;
    late Customer testCustomer;

    setUp(() {
      final now = DateTime(2026, 9, 10, 16, 27);
      testBill = Weighment(
        id: 1,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        customerId: 20,
        materialId: 30,
        grossWeightKg: 100000.0,
        tareWeightKg: 20000.0,
        netWeightKg: 80000.0,
        vehicleCharge: 1000.0,
        amount: 1000.0,
        paymentMode: 'Cash',
        remarks: 'Direct delivery to site',
        createdAt: now,
        updatedAt: now,
      );

      testCustomer = Customer(
        id: 20,
        name: 'BTC Construction Ltd',
        contactPerson: 'Mr. Rajesh',
        mobile: '9876543210',
        createdAt: now,
        updatedAt: now,
      );
    });

    testWidgets('renders weighbridge bill sections accurately', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeighmentSlipDialog(
              bill: testBill,
              customer: testCustomer,
              materialName: 'Sand',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Station Letterhead & Header. The business name appears in the
      // letterhead and again above the authorised signature.
      expect(find.text('VIYAN WEIGHBRIDGE'), findsWidgets);
      expect(find.text('Computer Weigh Bridge'), findsOneWidget);
      expect(find.text('24 HOURS SERVICE'), findsOneWidget);

      // 2. Receipt Title
      expect(find.text('WEIGHMENT RECEIPT'), findsOneWidget);

      // 3. Serial Number and Details
      expect(find.text('WB-00001'), findsOneWidget);
      expect(find.text('TN31CM2026'), findsOneWidget);
      expect(find.text('BTC Construction Ltd'), findsOneWidget);
      expect(find.text('Sand'), findsOneWidget);

      // 4. Weight Table
      expect(find.text('Gross Weight'), findsWidgets);
      expect(find.text('Tare Weight'), findsWidgets);
      expect(find.text('Net Weight'), findsWidgets);

      // 5. Remarks & Actions
      expect(find.text('Direct delivery to site'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Print Ticket'), findsOneWidget);
    });

    testWidgets('clicking Close closes the dialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => WeighmentSlipDialog(
                  bill: testBill,
                  customer: testCustomer,
                  materialName: 'Sand',
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The business name shows in the receipt header and above the
      // authorised signature.
      expect(find.text('VIYAN WEIGHBRIDGE'), findsWidgets);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('VIYAN WEIGHBRIDGE'), findsNothing);
    });
  });
}
