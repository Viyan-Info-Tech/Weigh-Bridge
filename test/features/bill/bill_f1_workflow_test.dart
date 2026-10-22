import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form.dart';

void main() {
  group('BillForm Weight Capture & Read-Only Display Tests', () {
    testWidgets(
      'renders GROSS and TARE type selectors and read-only captured boxes',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        String selectedType = 'Gross';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return BillForm(
                      billNumber: 'WB-00001',
                      grossWeightController: TextEditingController(),
                      tareWeightController: TextEditingController(),
                      remarksController: TextEditingController(),
                      materialController: TextEditingController(),
                      grossWeightKg: 25500.0,
                      tareWeightKg: 10200.0,
                      netWeightKg: 15300.0,
                      weightUnit: 'ton',
                      selectedType: selectedType,
                      onTypeChanged: (type) {
                        setState(() => selectedType = type);
                      },
                      onVehicleNumberChanged: (_) {},
                      onMaterialChanged: (_) {},
                      onGrossWeightChanged: (_) {},
                      onTareWeightChanged: (_) {},
                      onRemarksChanged: (_) {},
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Type Selector options
        expect(find.text('GROSS'), findsOneWidget);
        expect(find.text('TARE'), findsOneWidget);

        // Verify Read-Only Gross, Tare, and Nett displays
        expect(find.text('25.500'), findsOneWidget);
        expect(find.text('10.200'), findsOneWidget);
        expect(find.text('15.300'), findsOneWidget);

        // Verify Unit label Ton is present
        expect(find.text('Ton'), findsWidgets);

        // Tap on TARE selector
        await tester.tap(find.text('TARE'));
        await tester.pumpAndSettle();

        expect(selectedType, 'Tare');
      },
    );
  });
}
