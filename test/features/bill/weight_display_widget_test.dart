import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weight_display.dart';

void main() {
  Widget buildTestWidget({
    double netWeightTon = 0,
    double firstWeight = 0,
    double secondWeight = 0,
    String weightUnit = 'kg',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 800,
            height: 350,
            child: WeightDisplay(
              netWeightTon: netWeightTon,
              firstWeight: firstWeight,
              secondWeight: secondWeight,
              weightUnit: weightUnit,
            ),
          ),
        ),
      ),
    );
  }

  group('WeightDisplay Widget Tests', () {
    testWidgets('does not render SCALE 01, STABLE, ZERO, or standalone NET status indicators',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('SCALE 01'), findsNothing);
      expect(find.text('STABLE'), findsNothing);
      expect(find.text('ZERO'), findsNothing);
      expect(find.text('NET'), findsNothing);

      expect(find.text('kg'), findsOneWidget);
      expect(find.text('NET: 0 kg'), findsOneWidget);
      expect(find.text('1ST: 0 kg'), findsOneWidget);
      expect(find.text('2ND: 0 kg'), findsOneWidget);
    });

    testWidgets('displays correct weight values when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        netWeightTon: 5.0,
        firstWeight: 3000,
        secondWeight: 8000,
      ));
      await tester.pumpAndSettle();

      expect(find.text('NET: 5000 kg'), findsOneWidget);
      expect(find.text('1ST: 3000 kg'), findsOneWidget);
      expect(find.text('2ND: 8000 kg'), findsOneWidget);
    });

    testWidgets('does not render FIRST, SECOND, or TARE buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('FIRST'), findsNothing);
      expect(find.text('SECOND'), findsNothing);
      expect(find.text('TARE'), findsNothing);
    });
  });
}
