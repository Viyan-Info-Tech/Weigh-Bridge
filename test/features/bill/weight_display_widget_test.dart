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
    testWidgets('renders the scale readout with mode badge and unit label', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Branding and telemetry are always visible
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text('STABLE'), findsOneWidget);
      expect(find.text('MOTION'), findsOneWidget);
      expect(find.text('OVERLOAD'), findsOneWidget);
      expect(find.text('CAM 01'), findsOneWidget);
      expect(find.text('CAM 02'), findsOneWidget);

      // No FIRST / SECOND / TARE weight-control buttons in the display
      expect(find.text('FIRST'), findsNothing);
      expect(find.text('SECOND'), findsNothing);
    });

    testWidgets(
      'shows NET mode with the net weight when both weights entered',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            netWeightKg: 18000,
            grossWeight: 20000,
            tareWeight: 2000,
            weightUnit: 'ton',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('NET'), findsOneWidget);
        expect(find.text('Ton'), findsOneWidget);
      },
    );

    testWidgets(
      'computes and shows NET from the difference when both weights set',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            grossWeight: 20000,
            tareWeight: 2000,
            weightUnit: 'ton',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('NET'), findsOneWidget);
        expect(find.text('Ton'), findsOneWidget);
      },
    );

    testWidgets('shows GROSS mode when only a gross weight is entered', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(grossWeight: 20000, tareWeight: 0, weightUnit: 'ton'),
      );
      await tester.pumpAndSettle();

      expect(find.text('GROSS'), findsOneWidget);
      expect(find.text('Ton'), findsOneWidget);
    });

    testWidgets('shows TARE mode when only a tare weight is entered', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(grossWeight: 0, tareWeight: 2000, weightUnit: 'ton'),
      );
      await tester.pumpAndSettle();

      expect(find.text('TARE'), findsOneWidget);
      expect(find.text('Ton'), findsOneWidget);
    });

    testWidgets('shows ZERO mode when no weight is entered and kg units', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(weightUnit: 'kg'));
      await tester.pumpAndSettle();

      expect(find.text('ZERO'), findsOneWidget);
      expect(find.text('Kg'), findsOneWidget);
    });
  });
}
