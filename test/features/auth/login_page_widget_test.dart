import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/auth/domain/entities/user.dart';
import 'package:weighbridge/features/auth/domain/usecases/get_current_user.dart';
import 'package:weighbridge/features/auth/domain/usecases/is_authenticated.dart';
import 'package:weighbridge/features/auth/domain/usecases/login.dart';
import 'package:weighbridge/features/auth/domain/usecases/logout.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/pages/login_page.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockIsAuthenticatedUseCase extends Mock implements IsAuthenticatedUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsAuthenticatedUseCase mockIsAuthenticatedUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockIsAuthenticatedUseCase = MockIsAuthenticatedUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      isAuthenticatedUseCase: mockIsAuthenticatedUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider.value(
        value: authBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('renders desktop split-screen layout with branding and login form',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Branding elements on left
    expect(find.text('Accurate Weighing. Smarter Operations.'), findsOneWidget);
    expect(find.text('Digital\nRecords'), findsOneWidget);
    expect(find.text('Better\nInsights'), findsOneWidget);
    expect(find.text('Secure\n& Reliable'), findsOneWidget);
    expect(find.text('Weigh Today\nBuild Tomorrow'), findsOneWidget);
    expect(find.text('© 2026 Viyan Weighbridge. All rights reserved.'),
        findsOneWidget);

    // Verify Form elements on right
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.byKey(const Key('username_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('validates empty inputs on submit', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Username is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('submits login when inputs are valid', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testUser = User(
      id: 1,
      username: 'admin',
      role: 'admin',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );

    when(() => mockLoginUseCase('admin', 'secret123'))
        .thenAnswer((_) async => Right(testUser));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('username_field')), 'admin');
    await tester.enterText(
        find.byKey(const Key('password_field')), 'secret123');
    await tester.pump();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    verify(() => mockLoginUseCase('admin', 'secret123')).called(1);
  });

  testWidgets('renders gracefully on compact window sizes without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
