import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/customer/domain/usecases/create_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/deactivate_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/delete_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/load_customers.dart';
import 'package:weighbridge/features/customer/domain/usecases/search_customers.dart';
import 'package:weighbridge/features/customer/domain/usecases/update_customer.dart';
import 'package:weighbridge/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:weighbridge/features/customer/presentation/pages/customer_list_page.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockLoadCustomersUseCase extends Mock implements LoadCustomersUseCase {}

class MockCreateCustomerUseCase extends Mock implements CreateCustomerUseCase {}

class MockUpdateCustomerUseCase extends Mock implements UpdateCustomerUseCase {}

class MockDeactivateCustomerUseCase extends Mock
    implements DeactivateCustomerUseCase {}

class MockDeleteCustomerUseCase extends Mock implements DeleteCustomerUseCase {}

class MockSearchCustomersUseCase extends Mock
    implements SearchCustomersUseCase {}

void main() {
  late CustomerBloc customerBloc;
  late MockCustomerRepository mockRepository;
  late MockLoadCustomersUseCase mockLoadUseCase;
  late MockCreateCustomerUseCase mockCreateUseCase;
  late MockUpdateCustomerUseCase mockUpdateUseCase;
  late MockDeactivateCustomerUseCase mockDeactivateUseCase;
  late MockDeleteCustomerUseCase mockDeleteUseCase;
  late MockSearchCustomersUseCase mockSearchUseCase;

  final now = DateTime(2026, 9, 21);
  final testCustomers = [
    Customer(
      id: 1,
      customerCode: 'CUST-01',
      name: 'Alpha Traders',
      mobile: '9876543210',
      createdAt: now,
      updatedAt: now,
    ),
    Customer(
      id: 2,
      customerCode: 'CUST-02',
      name: 'Beta Minerals',
      mobile: '9123456780',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  setUp(() {
    mockRepository = MockCustomerRepository();
    mockLoadUseCase = MockLoadCustomersUseCase();
    mockCreateUseCase = MockCreateCustomerUseCase();
    mockUpdateUseCase = MockUpdateCustomerUseCase();
    mockDeactivateUseCase = MockDeactivateCustomerUseCase();
    mockDeleteUseCase = MockDeleteCustomerUseCase();
    mockSearchUseCase = MockSearchCustomersUseCase();

    when(
      () => mockLoadUseCase(isActive: null),
    ).thenAnswer((_) async => testCustomers);
    when(
      () => mockLoadUseCase(isActive: any(named: 'isActive')),
    ).thenAnswer((_) async => testCustomers);
    when(() => mockRepository.totalCustomerCount()).thenAnswer((_) async => 2);
    when(() => mockRepository.activeCustomerCount()).thenAnswer((_) async => 2);
    when(
      () => mockRepository.inactiveCustomerCount(),
    ).thenAnswer((_) async => 0);

    customerBloc = CustomerBloc(
      loadCustomersUseCase: mockLoadUseCase,
      createCustomerUseCase: mockCreateUseCase,
      updateCustomerUseCase: mockUpdateUseCase,
      deactivateCustomerUseCase: mockDeactivateUseCase,
      deleteCustomerUseCase: mockDeleteUseCase,
      searchCustomersUseCase: mockSearchUseCase,
      customerRepository: mockRepository,
    );
  });

  tearDown(() {
    customerBloc.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<CustomerBloc>.value(
        value: customerBloc,
        child: const CustomerListPage(),
      ),
    );
  }

  testWidgets(
    'Customer form follows 1 -> 2 -> 3 -> 4 FocusTraversalOrder on Tab',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 1. Initial focus is on Customer Code (autofocus)
      // The search field is on the right, the 3 form text fields are on the left
      final textFields = find.byType(TextField);
      // Find the fields by their controllers or labels
      final codeField = tester.widget<TextField>(textFields.at(0));
      final nameField = tester.widget<TextField>(textFields.at(1));
      final phoneField = tester.widget<TextField>(textFields.at(2));
      final saveButton = find.widgetWithText(FilledButton, 'Save Customer');

      expect(codeField.focusNode?.hasFocus, isTrue);

      // Tab -> Customer Name
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(nameField.focusNode?.hasFocus, isTrue);

      // Tab -> Phone Number
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(phoneField.focusNode?.hasFocus, isTrue);

      // Tab -> Save Customer button
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final saveBtnWidget = tester.widget<FilledButton>(saveButton);
      expect(saveBtnWidget.focusNode?.hasFocus, isTrue);
    },
  );

  testWidgets(
    'Customer form navigates via Enter key from Code -> Name -> Phone -> Save',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      final codeField = tester.widget<TextField>(textFields.at(0));
      final nameField = tester.widget<TextField>(textFields.at(1));
      final phoneField = tester.widget<TextField>(textFields.at(2));
      final saveButton = find.widgetWithText(FilledButton, 'Save Customer');

      // Code field is focused
      expect(codeField.focusNode?.hasFocus, isTrue);

      // Enter on Code field -> jumps to Name
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(nameField.focusNode?.hasFocus, isTrue);

      // Enter on Name field -> jumps to Phone
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(phoneField.focusNode?.hasFocus, isTrue);

      // Enter on Phone field -> jumps to Save Customer button
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      final saveBtnWidget = tester.widget<FilledButton>(saveButton);
      expect(saveBtnWidget.focusNode?.hasFocus, isTrue);
    },
  );

  testWidgets(
    'Customer list edit and delete buttons are excluded from form tab focus',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();

      // Verify ExcludeFocus wraps the edit and delete icon buttons
      final editButtons = find.byTooltip('Edit');
      final deleteButtons = find.byTooltip('Delete');
      expect(editButtons, findsNWidgets(2));
      expect(deleteButtons, findsNWidgets(2));

      for (var i = 0; i < 2; i++) {
        final editParent = find.ancestor(
          of: editButtons.at(i),
          matching: find.byType(ExcludeFocus),
        );
        final deleteParent = find.ancestor(
          of: deleteButtons.at(i),
          matching: find.byType(ExcludeFocus),
        );
        expect(editParent, findsWidgets);
        expect(deleteParent, findsWidgets);
      }
    },
  );
}
