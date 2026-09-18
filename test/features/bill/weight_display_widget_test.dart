import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weight_display.dart';

void main() {
  Widget buildTestWidget({
    double netWeightKg = 0,
    double grossWeight = 0,
    double tareWeight = 0,
    String weightUnit = 'kg',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 800,
            height: 350,
            child: WeightDisplay(
              netWeightKg: netWeightKg,
              grossWeight: grossWeight,
              tareWeight: tareWeight,
              weightUnit: weightUnit,
            ),
          ),
        ),
      ),
    );
  }

  group('WeightDisplay Widget Tests', () {
    testWidgets(
      'does not render SCALE 01, STABLE, ZERO, or standalone NET status indicators',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('SCALE 01'), findsNothing);
        expect(find.text('STABLE'), findsNothing);
        expect(find.text('ZERO'), findsNothing);
        expect(find.text('NET'), findsNothing);

        expect(find.text('kg'), findsOneWidget);
        expect(find.text('NET: 0 kg'), findsOneWidget);
        expect(find.text('GROSS: 0 kg'), findsOneWidget);
        expect(find.text('TARE: 0 kg'), findsOneWidget);
      },
    );

    testWidgets('displays correct weight values when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(netWeightKg: 5000, grossWeight: 3000, tareWeight: 8000),
      );
      await tester.pumpAndSettle();

      expect(find.text('NET: 5000 kg'), findsOneWidget);
      expect(find.text('GROSS: 3000 kg'), findsOneWidget);
      expect(find.text('TARE: 8000 kg'), findsOneWidget);
    });

    testWidgets('shows live Gross weight and dashes Net when Gross only entered', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(grossWeight: 20000, tareWeight: 0, weightUnit: 'ton'),
      );
      await tester.pumpAndSettle();

      expect(find.text('GROSS: 20.000 ton'), findsOneWidget);
      expect(find.text('TARE: 0 ton'), findsOneWidget);
      expect(find.text('NET: —'), findsOneWidget);
    });

    testWidgets('shows live Tare weight and dashes Gross and Net when Tare only entered', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(grossWeight: 0, tareWeight: 2000, weightUnit: 'ton'),
      );
      await tester.pumpAndSettle();

      expect(find.text('GROSS: —'), findsOneWidget);
      expect(find.text('TARE: 2.000 ton'), findsOneWidget);
      expect(find.text('NET: —'), findsOneWidget);
    });

    testWidgets('shows Net weight and all metrics when both weights entered', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          grossWeight: 20000,
          tareWeight: 2000,
          netWeightKg: 18000,
          weightUnit: 'ton',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GROSS: 20.000 ton'), findsOneWidget);
      expect(find.text('TARE: 2.000 ton'), findsOneWidget);
      expect(find.text('NET: 18.000 ton'), findsOneWidget);
    });

    testWidgets('does not render FIRST, SECOND, or TARE buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('FIRST'), findsNothing);
      expect(find.text('SECOND'), findsNothing);
      expect(find.text('TARE'), findsNothing);
    });
  });
}
