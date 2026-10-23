import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weighbridge/features/bill/presentation/widgets/bill_form_field_shell.dart';
import 'package:weighbridge/features/bill/presentation/widgets/searchable_dropdown.dart';

/// Reproduces the bill form's material field: a borderless SearchableDropdown
/// seated inside BillFormFieldShell (46px box, 1px border => 44px inner height).
///
/// Mirrors production: the material field is selection-only (`enableSearch:
/// false`), so the operator can only pick a saved material. Before the fix
/// this overflowed vertically by 4px (48px field in a 44px box).
Widget _harness({
  required ValueChanged<String> onChanged,
  String? selected,
  List<String> options = const ['Auto - Empty', 'Sand - Load', 'Gravel - Load'],
  Alignment alignment = Alignment.center,
  EdgeInsets padding = EdgeInsets.zero,
  bool enableSearch = false,
  String? emptyItemsMessage =
      'No materials available. Add a material in Material Management.',
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: ConstrainedBox(
            // Mirror the bill form's field height.
            constraints: const BoxConstraints.tightFor(height: 46),
            child: BillFormFieldShell(
              prefixIcon: Icons.inventory_2_outlined,
              child: SearchableDropdown<String>(
                label: 'MATERIAL',
                showLabel: false,
                borderless: true,
                enableSearch: enableSearch,
                emptyItemsMessage: emptyItemsMessage,
                items: options,
                selectedItem: selected,
                itemLabel: (v) => v,
                hintText: 'Select Material',
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'borderless dropdown fits the 44px shell without vertical overflow',
    (tester) async {
      String? picked;
      await tester.pumpWidget(_harness(onChanged: (v) => picked = v));
      await tester.pump();

      // The exact failure was a 4px RenderFlex overflow on the bottom.
      expect(tester.takeException(), isNull);
      // Nothing was selected yet, so the callback never fired.
      expect(picked, isNull);
    },
  );

  testWidgets('dropdown still opens, lists options, and selects a value', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(_harness(onChanged: (v) => picked = v));
    await tester.pump();

    // Open the overlay.
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.text('Auto - Empty'), findsWidgets);

    await tester.tap(find.text('Sand - Load').last);
    await tester.pumpAndSettle();

    expect(picked, 'Sand - Load');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selected value renders without overflow at short window heights',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _harness(onChanged: (_) {}, selected: 'Gravel - Load'),
      );
      await tester.pump();

      expect(find.text('Gravel - Load'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('popup opens below the field when there is room underneath', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(
        onChanged: (_) {},
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 16),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    final fieldRect = tester.getRect(find.byType(TextFormField));
    final optionRect = tester.getRect(find.text('Auto - Empty'));

    expect(optionRect.top, greaterThanOrEqualTo(fieldRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('popup flips above the field when there is no room below it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(
        onChanged: (_) {},
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 16),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    final fieldRect = tester.getRect(find.byType(TextFormField));
    final optionRect = tester.getRect(find.text('Auto - Empty'));

    // The options must sit fully above the field, not overlap it.
    expect(optionRect.bottom, lessThanOrEqualTo(fieldRect.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selected option shows a blue check and the popup renders as a card',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _harness(onChanged: (_) {}, selected: 'Sand - Load'),
      );
      await tester.pump();

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Selected value is marked with a check icon inside the popup.
      expect(find.text('Sand - Load'), findsWidgets);
      expect(find.byIcon(Icons.check_rounded), findsWidgets);
      // No overflow while the elevated popup is open.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selection-only field is read-only: typing "j" cannot change the value',
    (tester) async {
      String? picked;
      await tester.pumpWidget(
        _harness(
          onChanged: (v) => picked = v,
          selected: 'Train - Load',
          options: const ['Train - Load', 'Auto - Empty'],
        ),
      );
      await tester.pump();

      // Configured as a pure dropdown: no editing, no text caret.
      final inner = tester.widget<TextField>(find.byType(TextField));
      expect(inner.readOnly, isTrue);
      expect(inner.showCursor, isFalse);

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Try hard to force arbitrary text in. Either the read-only field
      // refuses the input connection (throws) or silently ignores it — the
      // selected material must not change and no selection may fire.
      try {
        await tester.enterText(find.byType(TextFormField), 'j');
        await tester.pumpAndSettle();
      } catch (_) {
        await tester.pumpAndSettle();
      }

      expect(picked, isNull);
      expect(find.text('j'), findsNothing);
      expect(find.text('Train - Load'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty list shows the material-management guidance message', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(onChanged: (_) {}, options: const []));
    await tester.pump();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No materials available. Add a material in Material Management.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Escape closes the popup without changing the selection', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      _harness(onChanged: (v) => picked = v, selected: 'Auto - Empty'),
    );
    await tester.pump();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    // Popup is open and lists an option that is not the current value.
    expect(find.text('Sand - Load'), findsWidgets);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    // Selection untouched (onChanged never fired) and the popup is gone.
    expect(picked, isNull);
    expect(find.text('Sand - Load'), findsNothing);
    expect(find.text('Auto - Empty'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared widget still supports search mode (type-to-filter)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        onChanged: (_) {},
        enableSearch: true,
        options: const ['Auto - Empty', 'Sand - Load', 'Gravel - Load'],
      ),
    );
    await tester.pump();

    final inner = tester.widget<TextField>(find.byType(TextField));
    expect(inner.readOnly, isFalse);

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'sand');
    await tester.pumpAndSettle();

    expect(find.text('Sand - Load'), findsWidgets);
    expect(find.text('Gravel - Load'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell renders a blue focus border while the field is active', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 46,
              child: BillFormFieldShell(
                isFocused: true,
                prefixIcon: Icons.inventory_2_outlined,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final hasBlueBorder = tester
        .widgetList<Container>(find.byType(Container))
        .any((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.border?.top.color == const Color(0xFF0D3B82) &&
              d.border?.top.width == 1.5;
        });

    expect(hasBlueBorder, isTrue, reason: 'focused shell uses the blue border');
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard: ArrowDown then Enter selects an option', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(_harness(onChanged: (v) => picked = v));
    await tester.pump();

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // ArrowDown highlights the first saved option, Enter commits it.
    expect(picked, 'Auto - Empty');
    expect(tester.takeException(), isNull);
  });
}
