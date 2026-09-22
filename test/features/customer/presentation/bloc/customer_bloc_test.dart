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
import 'package:weighbridge/features/customer/presentation/bloc/customer_event.dart';
import 'package:weighbridge/features/customer/presentation/bloc/customer_state.dart';

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
  late CustomerBloc bloc;
  late MockCustomerRepository mockRepository;
  late MockLoadCustomersUseCase mockLoadUseCase;
  late MockCreateCustomerUseCase mockCreateUseCase;
  late MockUpdateCustomerUseCase mockUpdateUseCase;
  late MockDeactivateCustomerUseCase mockDeactivateUseCase;
  late MockDeleteCustomerUseCase mockDeleteUseCase;
  late MockSearchCustomersUseCase mockSearchUseCase;

  final now = DateTime(2026, 9, 21);

  final testCustomer = Customer(
    id: 1,
    name: 'Test Customer',
    contactPerson: 'John',
    mobile: '9876543210',
    createdAt: now,
    updatedAt: now,
  );

  final testCustomers = [testCustomer];

  /// Set up mocks for the follow-up LoadCustomers that the BLoC dispatches
  /// internally after success events.
  void setUpLoadCustomersMocks() {
    when(
      () => mockLoadUseCase(isActive: any(named: 'isActive')),
    ).thenAnswer((_) async => testCustomers);
    when(() => mockRepository.totalCustomerCount()).thenAnswer((_) async => 1);
    when(() => mockRepository.activeCustomerCount()).thenAnswer((_) async => 1);
    when(
      () => mockRepository.inactiveCustomerCount(),
    ).thenAnswer((_) async => 0);
  }

  setUp(() {
    mockRepository = MockCustomerRepository();
    mockLoadUseCase = MockLoadCustomersUseCase();
    mockCreateUseCase = MockCreateCustomerUseCase();
    mockUpdateUseCase = MockUpdateCustomerUseCase();
    mockDeactivateUseCase = MockDeactivateCustomerUseCase();
    mockDeleteUseCase = MockDeleteCustomerUseCase();
    mockSearchUseCase = MockSearchCustomersUseCase();

    bloc = CustomerBloc(
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
    bloc.close();
  });

  /// Collect all states emitted while the given [action] runs, including
  /// the follow-up LoadCustomers states.
  Future<List<CustomerState>> collectStates(void Function() action) async {
    final states = <CustomerState>[];
    final sub = bloc.stream.listen(states.add);
    action();
    // Give time for follow-up async events to complete
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    return states;
  }

  group('CustomerBloc', () {
    test('initial state is CustomerState.initial', () {
      expect(bloc.state.status, CustomerStatus.initial);
      expect(bloc.state.customers, isEmpty);
    });

    group('LoadCustomers', () {
      test('emits loading then loaded with customers', () async {
        when(
          () => mockLoadUseCase(isActive: null),
        ).thenAnswer((_) async => testCustomers);
        when(
          () => mockRepository.totalCustomerCount(),
        ).thenAnswer((_) async => 1);
        when(
          () => mockRepository.activeCustomerCount(),
        ).thenAnswer((_) async => 1);
        when(
          () => mockRepository.inactiveCustomerCount(),
        ).thenAnswer((_) async => 0);

        final states = await collectStates(() {
          bloc.add(const LoadCustomers());
        });

        expect(states.any((s) => s.status == CustomerStatus.loading), isTrue);
        expect(states.any((s) => s.status == CustomerStatus.loaded), isTrue);
        expect(bloc.state.customers, testCustomers);
      });

      test('emits error when load fails', () async {
        when(
          () => mockLoadUseCase(isActive: null),
        ).thenThrow(Exception('Database error'));

        bloc.add(const LoadCustomers());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, CustomerStatus.error);
        expect(bloc.state.errorMessage, contains('Database error'));
      });

      test('loads active customers when filterActive is true', () async {
        when(
          () => mockLoadUseCase(isActive: true),
        ).thenAnswer((_) async => testCustomers);
        when(
          () => mockRepository.totalCustomerCount(),
        ).thenAnswer((_) async => 1);
        when(
          () => mockRepository.activeCustomerCount(),
        ).thenAnswer((_) async => 1);
        when(
          () => mockRepository.inactiveCustomerCount(),
        ).thenAnswer((_) async => 0);

        await collectStates(() {
          bloc.add(const LoadCustomers(filterActive: true));
        });

        expect(bloc.state.filterActive, isTrue);
        expect(bloc.state.customers, testCustomers);
      });
    });

    group('LoadCustomerDetail', () {
      test('loads customer by id', () async {
        when(
          () => mockRepository.getCustomerById(1),
        ).thenAnswer((_) async => testCustomer);

        bloc.add(const LoadCustomerDetail(1));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, CustomerStatus.loaded);
        expect(bloc.state.selectedCustomer, testCustomer);
      });

      test('returns null customer when not found', () async {
        when(
          () => mockRepository.getCustomerById(999),
        ).thenAnswer((_) async => null);

        bloc.add(const LoadCustomerDetail(999));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, CustomerStatus.loaded);
        expect(bloc.state.selectedCustomer, isNull);
      });
    });

    group('CreateCustomerRequested', () {
      test('emits success then follow-up loaded', () async {
        when(
          () => mockCreateUseCase(name: 'New Customer'),
        ).thenAnswer((_) async => 42);
        setUpLoadCustomersMocks();

        final states = await collectStates(() {
          bloc.add(const CreateCustomerRequested(name: 'New Customer'));
        });

        // The BLoC emits success then dispatches LoadCustomers
        final successStates = states
            .where((s) => s.status == CustomerStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('created'));
        expect(bloc.state.status, CustomerStatus.loaded);
        verify(() => mockCreateUseCase(name: 'New Customer')).called(1);
      });

      test('emits error when creation fails', () async {
        when(
          () => mockCreateUseCase(name: 'Fail'),
        ).thenThrow(Exception('Duplicate'));

        bloc.add(const CreateCustomerRequested(name: 'Fail'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, CustomerStatus.error);
      });
    });

    group('UpdateCustomerRequested', () {
      test('emits success then follow-up loaded', () async {
        when(
          () => mockUpdateUseCase(id: 1, name: 'Updated'),
        ).thenAnswer((_) async => true);
        setUpLoadCustomersMocks();

        final states = await collectStates(() {
          bloc.add(const UpdateCustomerRequested(id: 1, name: 'Updated'));
        });

        final successStates = states
            .where((s) => s.status == CustomerStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('updated'));
        expect(bloc.state.status, CustomerStatus.loaded);
      });
    });

    group('DeactivateCustomerRequested', () {
      test('deactivates customer and reloads', () async {
        when(() => mockDeactivateUseCase(1)).thenAnswer((_) async {});
        setUpLoadCustomersMocks();

        final states = await collectStates(() {
          bloc.add(const DeactivateCustomerRequested(1));
        });

        final successStates = states
            .where((s) => s.status == CustomerStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('deactivated'));
        expect(bloc.state.status, CustomerStatus.loaded);
      });
    });

    group('DeleteCustomerRequested', () {
      test('deletes customer and reloads', () async {
        when(() => mockDeleteUseCase(1)).thenAnswer((_) async {});
        when(
          () => mockLoadUseCase(isActive: any(named: 'isActive')),
        ).thenAnswer((_) async => <Customer>[]);
        when(
          () => mockRepository.totalCustomerCount(),
        ).thenAnswer((_) async => 0);
        when(
          () => mockRepository.activeCustomerCount(),
        ).thenAnswer((_) async => 0);
        when(
          () => mockRepository.inactiveCustomerCount(),
        ).thenAnswer((_) async => 0);

        final states = await collectStates(() {
          bloc.add(const DeleteCustomerRequested(1));
        });

        final successStates = states
            .where((s) => s.status == CustomerStatus.success)
            .toList();
        expect(successStates, isNotEmpty);
        expect(successStates.last.successMessage, contains('deleted'));
        expect(bloc.state.status, CustomerStatus.loaded);
      });
    });

    group('SearchCustomers', () {
      test('searches and returns results', () async {
        when(
          () => mockSearchUseCase('ACME'),
        ).thenAnswer((_) async => testCustomers);

        bloc.add(const SearchCustomers('ACME'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.status, CustomerStatus.loaded);
        expect(bloc.state.customers, testCustomers);
        expect(bloc.state.searchQuery, 'ACME');
      });

      test('empty query triggers LoadCustomers', () async {
        setUpLoadCustomersMocks();

        final states = await collectStates(() {
          bloc.add(const SearchCustomers(''));
        });

        expect(states.any((s) => s.status == CustomerStatus.loaded), isTrue);
      });
    });

    group('FilterCustomersByStatus', () {
      test('delegates to LoadCustomers with filter', () async {
        setUpLoadCustomersMocks();

        final states = await collectStates(() {
          bloc.add(const FilterCustomersByStatus(true));
        });

        expect(bloc.state.filterActive, isTrue);
        expect(states.any((s) => s.status == CustomerStatus.loaded), isTrue);
      });
    });
  });
}
