import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weight_display.dart';

void main() {
  Widget buildTestWidget({
    double netWeightTon = 2.000,
    double firstWeight = 0,
    double secondWeight = 0,
    VoidCallback? onFirstPressed,
    VoidCallback? onSecondPressed,
    VoidCallback? onTarePressed,
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
              onFirstPressed: onFirstPressed,
              onSecondPressed: onSecondPressed,
              onTarePressed: onTarePressed,
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

      // Ensure SCALE 01, STABLE, ZERO are removed
      expect(find.text('SCALE 01'), findsNothing);
      expect(find.text('STABLE'), findsNothing);
      expect(find.text('ZERO'), findsNothing);

      // Ensure standalone NET indicator is removed (only the summary breakdown NET: 2000 kg remains)
      expect(find.text('NET'), findsNothing);

      // Ensure unit and summary breakdown are present
      expect(find.text('ton'), findsOneWidget);
      expect(find.text('NET: 2000 kg'), findsOneWidget);
      expect(find.text('1ST: 0 kg'), findsOneWidget);
      expect(find.text('2ND: 0 kg'), findsOneWidget);

      // Ensure action buttons are present
      expect(find.text('FIRST'), findsOneWidget);
      expect(find.text('SECOND'), findsOneWidget);
      expect(find.text('TARE'), findsOneWidget);
    });

    testWidgets('triggers callback buttons when pressed', (tester) async {
      bool firstTapped = false;
      bool secondTapped = false;
      bool tareTapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          onFirstPressed: () => firstTapped = true,
          onSecondPressed: () => secondTapped = true,
          onTarePressed: () => tareTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('FIRST'));
      expect(firstTapped, isTrue);

      await tester.tap(find.text('SECOND'));
      expect(secondTapped, isTrue);

      await tester.tap(find.text('TARE'));
      expect(tareTapped, isTrue);
    });
  });
}
