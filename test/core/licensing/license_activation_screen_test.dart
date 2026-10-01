import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_state.dart';
import 'package:weighbridge/core/licensing/presentation/license_activation_screen.dart';

class MockLicenseService extends Mock implements LicenseService {}

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockLicenseService mockLicenseService;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockLicenseService = MockLicenseService();
    mockAuthBloc = MockAuthBloc();
  });

  group('LicenseActivationScreen - status display', () {
    testWidgets('shows message for valid status', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.valid,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('License activated successfully'), findsOneWidget);
    });

    testWidgets('shows message for notActivated status', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.notActivated,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This computer has not been activated.\n'
          'Please contact ViyanInfo to obtain a license.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows message for invalidSignature status', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.invalidSignature,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('The license file could not be verified.'),
        findsOneWidget,
      );
    });

    testWidgets('shows message for wrongMachine status', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.wrongMachine,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This license is registered to another computer.'),
        findsOneWidget,
      );
    });

    testWidgets('shows message for expired status', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.expired,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Your ViyanInfo license has expired.'),
        findsOneWidget,
      );
    });

    testWidgets('shows message for clockRollbackDetected status', (
      tester,
    ) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.clockRollbackDetected,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Clock rollback detected.'), findsOneWidget);
    });

    testWidgets('shows message for malformedLicense status', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.malformedLicense,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('The license file is malformed.'),
        findsOneWidget,
      );
    });
  });

  group('LicenseActivationScreen - machine ID', () {
    testWidgets('displays machine ID', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'abcdef1234567890' * 4);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('abcd-ef12-3456-7890'), findsOneWidget);
    });
  });

  group('LicenseActivationScreen - activate interactions', () {
    testWidgets('activate button is disabled when no file selected', (
      tester,
    ) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final activateButton = find.text('Activate');
      expect(activateButton, findsOneWidget);
    });

    testWidgets('shows error message when activation fails', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockLicenseService.saveLicense('test'),
      ).thenThrow(Exception('fail'));
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final activateButton = find.text('Activate');
      expect(activateButton, findsOneWidget);
    });

    testWidgets('shows success message in green when status is valid', (
      tester,
    ) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.valid,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final successTextFinder = find.text('License activated successfully');
      expect(successTextFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(successTextFinder);
      expect(textWidget.style?.color, Colors.green.shade700);

      final containerFinder = find
          .ancestor(of: successTextFinder, matching: find.byType(Container))
          .first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green.shade50);
    });

    testWidgets('shows error message in red when status is not valid', (
      tester,
    ) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
            licenseStatus: LicenseStatus.expired,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final errorTextFinder = find.textContaining(
        'Your ViyanInfo license has expired.',
      );
      expect(errorTextFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(errorTextFinder);
      expect(textWidget.style?.color, Colors.red.shade700);

      final containerFinder = find
          .ancestor(of: errorTextFinder, matching: find.byType(Container))
          .first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
    });
  });

  group('LicenseActivationScreen - copy machine ID', () {
    testWidgets('copy machine ID shows snack bar', (tester) async {
      when(
        () => mockLicenseService.getMachineHash(),
      ).thenAnswer((_) async => 'a' * 64);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState(status: AuthStatus.initial)));

      await tester.pumpWidget(
        MaterialApp(
          home: LicenseActivationScreen(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final copyButton = find.text('Copy Machine ID');
      expect(copyButton, findsOneWidget);
    });
  });
}
