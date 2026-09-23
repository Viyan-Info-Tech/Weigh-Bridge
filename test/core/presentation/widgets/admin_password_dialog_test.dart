import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/presentation/widgets/admin_password_dialog.dart';

void main() {
  testWidgets('AdminPasswordDialog renders beautifully and unlocks with 123', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showAdminPasswordDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    // Tap to open
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify dialog elements
    expect(find.text('Administrator Access'), findsOneWidget);
    expect(find.text('Enter password to continue'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);

    // Enter wrong password
    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect password. Please try again.'), findsOneWidget);
    expect(result, isNull);

    // Enter correct password
    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('AdminPasswordDialog cancels on Cancel button and Escape key', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showAdminPasswordDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    // Test Cancel button
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);

    // Test Escape key
    result = null;
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
