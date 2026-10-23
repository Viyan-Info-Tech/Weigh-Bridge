import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form_weight_row.dart';

/// The SECOND WEIGHT toggle is a separate button next to (never inside) the
/// TYPE options. Activating it hides GROSS/TARE and shows the lookup status
/// banner; the previous weight's field is locked while its twin stays
/// editable for the current capture.
void main() {
  Future<void> pumpForm(
    WidgetTester tester, {
    required BillStateLike state,
    required VoidCallback onSecondWeightToggle,
  }) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BillForm(
              billNumber: 'WB-00001',
              grossWeightController: TextEditingController(),
              tareWeightController: TextEditingController(),
              remarksController: TextEditingController(),
              materialController: TextEditingController(),
              vehicleNumberController: TextEditingController(),
              chargesController: TextEditingController(),
              netWeightKg: 0,
              onVehicleNumberChanged: (_) {},
              onMaterialChanged: (_) {},
              onGrossWeightChanged: (_) {},
              onTareWeightChanged: (_) {},
              onRemarksChanged: (_) {},
              isSecondWeightMode: state.isSecondWeightMode,
              isFetchingPreviousWeight: state.isFetchingPreviousWeight,
              previousWeightType: state.previousWeightType,
              previousBillNumber: state.previousBillNumber,
              previousWeightText: state.previousWeightText,
              previousWeightMessage: state.previousWeightMessage,
              onSecondWeightToggle: onSecondWeightToggle,
            ),
          ),
        ),
      ),
    );
  }

  /// Minimal view of the second-weight inputs the form consumes.
  const normalState = BillStateLike();

  testWidgets(
    'normal mode: GROSS and TARE options render beside the SECOND WEIGHT '
    'button, all editable',
    (tester) async {
      var toggled = false;
      await pumpForm(
        tester,
        state: normalState,
        onSecondWeightToggle: () => toggled = true,
      );

      expect(find.text('GROSS'), findsOneWidget);
      expect(find.text('TARE'), findsOneWidget);
      expect(find.text('SECOND WEIGHT'), findsOneWidget);

      // The button is separate from the TYPE options and toggles the mode.
      await tester.tap(find.text('SECOND WEIGHT'));
      expect(toggled, isTrue);
    },
  );

  testWidgets(
    'second-weight mode: GROSS and TARE disappear, the active toggle and the '
    'matched-bill banner render instead',
    (tester) async {
      await pumpForm(
        tester,
        state: const BillStateLike(
          isSecondWeightMode: true,
          previousWeightType: 'GROSS',
          previousBillNumber: 'WB-00001',
          previousWeightText: '14.710 ton',
        ),
        onSecondWeightToggle: () {},
      );

      // The TYPE options are hidden entirely.
      expect(find.text('GROSS'), findsNothing);
      expect(find.text('TARE'), findsNothing);
      // The separate toggle and the banner about the loaded bill render.
      expect(find.text('SECOND WEIGHT'), findsOneWidget);
      expect(find.textContaining('loaded from bill WB-00001'), findsOneWidget);
      expect(find.textContaining('locked'), findsOneWidget);
    },
  );

  testWidgets(
    'second-weight mode without a match: the "not found" message is shown',
    (tester) async {
      await pumpForm(
        tester,
        state: const BillStateLike(
          isSecondWeightMode: true,
          previousWeightMessage:
              'No previous weighment found for TN31CM2026.',
        ),
        onSecondWeightToggle: () {},
      );

      expect(
        find.text('No previous weighment found for TN31CM2026.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'second-weight mode: the previous weight field is locked while its twin '
    'stays editable',
    (tester) async {
      await pumpForm(
        tester,
        state: const BillStateLike(
          isSecondWeightMode: true,
          previousWeightType: 'GROSS',
          previousBillNumber: 'WB-00001',
          previousWeightText: '14.710 ton',
        ),
        onSecondWeightToggle: () {},
      );

      // The gross box (previous weight, locked) vs the tare box (current
      // capture, editable). The weight rows are the only enabled/disabled
      // weight TextFields on the form.
      final grossRow = tester.widget<BillFormWeightRow>(
        find.byKey(const Key('gross_weight_row')),
      );
      final tareRow = tester.widget<BillFormWeightRow>(
        find.byKey(const Key('tare_weight_row')),
      );
      expect(
        grossRow.enabled,
        isFalse,
        reason: 'the previous weight field must be locked',
      );
      expect(
        tareRow.enabled,
        isTrue,
        reason: 'the capture field stays editable',
      );
    },
  );

  testWidgets(
    'the form fits a narrow desktop window in second-weight mode',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BillForm(
                billNumber: 'WB-00001',
                grossWeightController: TextEditingController(),
                tareWeightController: TextEditingController(),
                remarksController: TextEditingController(),
                materialController: TextEditingController(),
                vehicleNumberController: TextEditingController(),
                netWeightKg: 0,
                onVehicleNumberChanged: (_) {},
                onMaterialChanged: (_) {},
                onGrossWeightChanged: (_) {},
                onTareWeightChanged: (_) {},
                onRemarksChanged: (_) {},
                isSecondWeightMode: true,
                previousWeightType: 'TARE',
                previousBillNumber: 'WB-00001',
                previousWeightText: '10.000 ton',
                onSecondWeightToggle: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('SECOND WEIGHT'), findsOneWidget);
      expect(find.text('GROSS'), findsNothing);
    },
  );
}

/// Tiny value holder mirroring the second-weight subset of [BillState], so
/// this widget test does not need the whole bloc state graph.
class BillStateLike {
  const BillStateLike({
    this.isSecondWeightMode = false,
    this.isFetchingPreviousWeight = false,
    this.previousWeightType,
    this.previousBillNumber,
    this.previousWeightText,
    this.previousWeightMessage,
  });

  final bool isSecondWeightMode;
  final bool isFetchingPreviousWeight;
  final String? previousWeightType;
  final String? previousBillNumber;
  final String? previousWeightText;
  final String? previousWeightMessage;
}
