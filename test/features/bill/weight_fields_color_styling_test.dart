import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form_readonly_fields.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form_weight_row.dart';

void main() {
  group('Weight Fields Color Styling Tests', () {
    testWidgets(
      'Gross Weight: only numeric value is green Color(0xFF16A34A), bold, 24pt',
      (tester) async {
        final controller = TextEditingController(text: '15400');
        final now = DateTime.now();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BillFormWeightRow(
                controller: controller,
                weightKg: 15400,
                weightUnit: 'kg',
                enabled: true,
                isCaptured: true,
                date: now,
                time: TimeOfDay.fromDateTime(now),
                onSelectDate: (_) {},
                onSelectTime: (_) {},
                onWeightChanged: (_) {},
                accent: WeightRowAccent.green,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.color, const Color(0xFF16A34A));
        expect(textField.style?.fontWeight, FontWeight.bold);
        expect(textField.style?.fontSize, 24);

        // Verify decoration and container remain normal neutral appearance
        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(Container),
              )
              .first,
        );
        final boxDecoration = container.decoration as BoxDecoration?;
        expect(boxDecoration?.color, const Color(0xFFF8FAFC));
        final border = boxDecoration?.border as Border?;
        expect(border?.top.color, const Color(0xFFCBD5E1));

        // Prefix icon is neutral 0xFF64748B
        final icon = tester.widget<Icon>(find.byIcon(Icons.scale_rounded));
        expect(icon.color, const Color(0xFF64748B));

        // Unit text is neutral 0xFF334155
        final unitText = tester.widget<Text>(find.text('Kg'));
        expect(unitText.style?.color, const Color(0xFF334155));
      },
    );

    testWidgets(
      'Tare Weight: only numeric value is red Color(0xFFDC2626), bold, 24pt',
      (tester) async {
        final controller = TextEditingController(text: '5200');
        final now = DateTime.now();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BillFormWeightRow(
                controller: controller,
                weightKg: 5200,
                weightUnit: 'kg',
                enabled: true,
                isCaptured: true,
                date: now,
                time: TimeOfDay.fromDateTime(now),
                onSelectDate: (_) {},
                onSelectTime: (_) {},
                onWeightChanged: (_) {},
                accent: WeightRowAccent.red,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.color, const Color(0xFFDC2626));
        expect(textField.style?.fontWeight, FontWeight.bold);
        expect(textField.style?.fontSize, 24);

        // Verify container and decoration remain normal neutral appearance
        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(Container),
              )
              .first,
        );
        final boxDecoration = container.decoration as BoxDecoration?;
        expect(boxDecoration?.color, const Color(0xFFF8FAFC));
        final border = boxDecoration?.border as Border?;
        expect(border?.top.color, const Color(0xFFCBD5E1));

        // Prefix icon is neutral 0xFF64748B
        final icon = tester.widget<Icon>(find.byIcon(Icons.scale_rounded));
        expect(icon.color, const Color(0xFF64748B));

        // Unit text is neutral 0xFF334155
        final unitText = tester.widget<Text>(find.text('Kg'));
        expect(unitText.style?.color, const Color(0xFF334155));
      },
    );

    testWidgets(
      'Net Weight: only numeric value is blue Color(0xFF0284C7), bold, 24pt',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BillFormNetWeightDisplay(
                grossWeightKg: 15400,
                tareWeightKg: 5200,
                netWeightKg: 10200,
                weightUnit: 'kg',
              ),
            ),
          ),
        );

        final netText = tester.widget<Text>(find.text('10200'));
        expect(netText.style?.color, const Color(0xFF0284C7));
        expect(netText.style?.fontWeight, FontWeight.bold);
        expect(netText.style?.fontSize, 24);

        // Verify container and decoration remain normal neutral appearance
        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('10200'),
                matching: find.byType(Container),
              )
              .first,
        );
        final boxDecoration = container.decoration as BoxDecoration?;
        expect(boxDecoration?.color, const Color(0xFFF8FAFC));
        final border = boxDecoration?.border as Border?;
        expect(border?.top.color, const Color(0xFFCBD5E1));

        // Prefix icon is neutral 0xFF64748B
        final icon = tester.widget<Icon>(find.byIcon(Icons.scale_rounded));
        expect(icon.color, const Color(0xFF64748B));

        // Unit text is neutral 0xFF334155
        final unitText = tester.widget<Text>(find.text('Kg'));
        expect(unitText.style?.color, const Color(0xFF334155));
      },
    );

    testWidgets('Date/Time rows retain normal neutral styling when captured', (
      tester,
    ) async {
      final controller = TextEditingController(text: '15400');
      final now = DateTime(2026, 10, 14, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillFormWeightRow(
              controller: controller,
              weightKg: 15400,
              weightUnit: 'kg',
              enabled: true,
              isCaptured: true,
              date: now,
              time: TimeOfDay.fromDateTime(now),
              onSelectDate: (_) {},
              onSelectTime: (_) {},
              onWeightChanged: (_) {},
              accent: WeightRowAccent.green,
            ),
          ),
        ),
      );

      // Date chip icon and text
      final calIcon = tester.widget<Icon>(
        find.byIcon(Icons.calendar_month_outlined),
      );
      expect(calIcon.color, const Color(0xFF475569));

      final dateText = tester.widget<Text>(find.text('14/10/2026'));
      expect(dateText.style?.color, const Color(0xFF0F172A));

      // Time chip icon and text
      final timeIcon = tester.widget<Icon>(
        find.byIcon(Icons.access_time_rounded),
      );
      expect(timeIcon.color, const Color(0xFF475569));

      final timeText = tester.widget<Text>(find.text('2:30 PM'));
      expect(timeText.style?.color, const Color(0xFF0F172A));
    });
  });
}
