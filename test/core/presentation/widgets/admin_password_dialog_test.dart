import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:weighbridge/core/presentation/widgets/admin_password_dialog.dart';
import 'package:weighbridge/core/security/admin_password_service.dart';

class _FakeAdminPasswordService implements AdminPasswordService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> verify(String password) async => password == '123';

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}
}

void main() {
  testWidgets('AdminPasswordDialog renders beautifully and unlocks with 123', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      Provider<AdminPasswordService>.value(
        value: _FakeAdminPasswordService(),
        child: MaterialApp(
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

    // The password field receives focus automatically so the user can type
    // immediately without clicking it first (Windows desktop behaviour).
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    final passwordField = tester.widget<TextField>(find.byType(TextField));
    expect(passwordField.focusNode?.hasFocus, isTrue);

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
      Provider<AdminPasswordService>.value(
        value: _FakeAdminPasswordService(),
        child: MaterialApp(
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

  testWidgets('opening the dialog steals focus from the field behind it', (
    tester,
  ) async {
    final backgroundFocus = FocusNode();
    addTearDown(backgroundFocus.dispose);

    await tester.pumpWidget(
      Provider<AdminPasswordService>.value(
        value: _FakeAdminPasswordService(),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  focusNode: backgroundFocus,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number',
                  ),
                ),
                Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showAdminPasswordDialog(context),
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(backgroundFocus.hasFocus, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    final dialogField = tester.widget<TextField>(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      ),
    );

    expect(backgroundFocus.hasFocus, isFalse);
    expect(dialogField.focusNode?.hasFocus, isTrue);
  });
}
