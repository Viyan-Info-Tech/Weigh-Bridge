import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/presentation/widgets/preprinted_ticket_preview.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

void main() {
  final weighmentAt = DateTime(2026, 9, 10, 16, 27);

  Weighment bill() => Weighment(
    id: 1,
    billNumber: 'WB-00042',
    vehicleNumber: 'TN31CM2026',
    firstWeightKg: 100000,
    firstWeightType: 'GROSS',
    secondWeightKg: 20000,
    charges: 250.5,
    material: 'Cement',
    createdAt: weighmentAt,
    updatedAt: weighmentAt,
  );

  testWidgets('renders each copy from its own field grid', (tester) async {
    final settings = BillingSettings(
      updatedAt: weighmentAt,
      printFieldGrid: '{"vehicle":{"c":14,"l":1,"w":22,"fs":12,"b":true}}',
      printRightFieldGrid:
          '{"vehicle":{"c":24,"l":4,"w":18,"fs":15,"b":false}}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 800,
              child: PrePrintedTicketPreview(
                bill: bill(),
                settings: settings,
                showCaption: false,
              ),
            ),
          ),
        ),
      ),
    );

    final vehicleTexts = find.text('TN31CM2026');
    expect(vehicleTexts, findsNWidgets(2));

    final left = tester.getTopLeft(vehicleTexts.at(0));
    final right = tester.getTopLeft(vehicleTexts.at(1));

    // Both copies are visible side by side, but the right copy uses its own
    // column and line instead of mirroring the left one.
    expect(right.dx, greaterThan(left.dx));
    expect(right.dy, greaterThan(left.dy));

    final leftStyle = tester.widget<Text>(vehicleTexts.at(0)).style;
    final rightStyle = tester.widget<Text>(vehicleTexts.at(1)).style;
    expect(leftStyle?.fontWeight, FontWeight.w700);
    expect(rightStyle?.fontWeight, FontWeight.w400);
    expect(rightStyle!.fontSize!, greaterThan(leftStyle!.fontSize!));
  });
}
