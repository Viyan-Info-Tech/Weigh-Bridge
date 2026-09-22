import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/presentation/license_activation_screen.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_state.dart';

class MockLicenseService extends Mock implements LicenseService {}

class MockAuthBloc extends Mock implements AuthBloc {}

class TestableLicenseGate extends StatefulWidget {
  final LicenseService licenseService;
  final AuthBloc authBloc;

  const TestableLicenseGate({
    super.key,
    required this.licenseService,
    required this.authBloc,
  });

  @override
  State<TestableLicenseGate> createState() => _TestableLicenseGateState();
}

class _TestableLicenseGateState extends State<TestableLicenseGate> {
  late Future<LicenseStatus> _validationFuture;
  late StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _validationFuture = widget.licenseService.validate();
    _authSubscription = widget.authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        widget.licenseService.validate().then((status) {
          if (mounted) {
            setState(() {
              _validationFuture = Future.value(status);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LicenseStatus>(
      future: _validationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final status = snapshot.data ?? LicenseStatus.notActivated;
        if (status == LicenseStatus.valid) {
          return const SizedBox(key: Key('weighbridge_app'));
        }
        return LicenseActivationScreen(
          licenseService: widget.licenseService,
          authBloc: widget.authBloc,
          licenseStatus: status,
        );
      },
    );
  }
}

void main() {
  late MockLicenseService mockLicenseService;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockLicenseService = MockLicenseService();
    mockAuthBloc = MockAuthBloc();
  });

  group('LicenseGate routing behavior', () {
    testWidgets('shows loading indicator initially', (tester) async {
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.notActivated);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState()));

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('routes to app widget when license is valid', (tester) async {
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.valid);
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthState(status: AuthStatus.authenticated)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('weighbridge_app')), findsOneWidget);
    });

    testWidgets('routes to LicenseActivationScreen when not activated', (
      tester,
    ) async {
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.notActivated);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState()));

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LicenseActivationScreen), findsOneWidget);
    });

    testWidgets('routes to LicenseActivationScreen for expired license', (
      tester,
    ) async {
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.expired);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState()));

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LicenseActivationScreen), findsOneWidget);
    });

    testWidgets('routes to LicenseActivationScreen for invalid signature', (
      tester,
    ) async {
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.invalidSignature);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState()));

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LicenseActivationScreen), findsOneWidget);
    });

    testWidgets('routes to LicenseActivationScreen for clock rollback', (
      tester,
    ) async {
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.clockRollbackDetected);
      when(
        () => mockAuthBloc.stream,
      ).thenAnswer((_) => Stream.value(AuthState()));

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LicenseActivationScreen), findsOneWidget);
    });

    testWidgets('re-validates license when auth becomes authenticated', (
      tester,
    ) async {
      var licenseStatus = LicenseStatus.notActivated;
      when(
        () => mockLicenseService.validate(),
      ).thenAnswer((_) async => licenseStatus);

      late Stream<AuthState> authStream;
      when(() => mockAuthBloc.stream).thenAnswer((_) => authStream);

      await tester.pumpWidget(
        MaterialApp(
          home: TestableLicenseGate(
            licenseService: mockLicenseService,
            authBloc: mockAuthBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LicenseActivationScreen), findsOneWidget);

      licenseStatus = LicenseStatus.valid;
      authStream = Stream.value(AuthState(status: AuthStatus.authenticated));
      await tester.pump();

      expect(find.byKey(const Key('weighbridge_app')), findsOneWidget);
    });
  });
}
