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

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late MockCustomerRepository mockRepository;

  final now = DateTime(2026, 9, 21);

  final testCustomer = Customer(
    id: 1,
    name: 'Test Customer',
    contactPerson: 'John',
    mobile: '9876543210',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockCustomerRepository();
  });

  group('LoadCustomersUseCase', () {
    test('loads all customers when no filter', () async {
      when(
        () => mockRepository.getAllCustomers(),
      ).thenAnswer((_) async => [testCustomer]);

      final useCase = LoadCustomersUseCase(mockRepository);
      final result = await useCase();

      expect(result, [testCustomer]);
      verify(() => mockRepository.getAllCustomers()).called(1);
    });

    test('loads active customers when filterActive is true', () async {
      when(
        () => mockRepository.getCustomersByStatus(isActive: true),
      ).thenAnswer((_) async => [testCustomer]);

      final useCase = LoadCustomersUseCase(mockRepository);
      final result = await useCase(isActive: true);

      expect(result, [testCustomer]);
      verify(
        () => mockRepository.getCustomersByStatus(isActive: true),
      ).called(1);
    });

    test('loads inactive customers when filterActive is false', () async {
      when(
        () => mockRepository.getCustomersByStatus(isActive: false),
      ).thenAnswer((_) async => []);

      final useCase = LoadCustomersUseCase(mockRepository);
      final result = await useCase(isActive: false);

      expect(result, isEmpty);
      verify(
        () => mockRepository.getCustomersByStatus(isActive: false),
      ).called(1);
    });
  });

  group('CreateCustomerUseCase', () {
    test('creates customer when name is unique', () async {
      when(
        () => mockRepository.searchCustomers('New Customer'),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.createCustomer(
          name: 'New Customer',
          contactPerson: 'Jane',
        ),
      ).thenAnswer((_) async => 42);

      final useCase = CreateCustomerUseCase(mockRepository);
      final id = await useCase(name: 'New Customer', contactPerson: 'Jane');

      expect(id, 42);
      verify(() => mockRepository.searchCustomers('New Customer')).called(1);
      verify(
        () => mockRepository.createCustomer(
          name: 'New Customer',
          contactPerson: 'Jane',
        ),
      ).called(1);
    });

    test('throws when customer with same name exists', () async {
      when(
        () => mockRepository.searchCustomers(testCustomer.name),
      ).thenAnswer((_) async => [testCustomer]);

      final useCase = CreateCustomerUseCase(mockRepository);

      expect(
        () => useCase(name: testCustomer.name),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test('allows duplicate names with different case', () async {
      when(
        () => mockRepository.searchCustomers('ACME'),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.createCustomer(name: 'ACME'),
      ).thenAnswer((_) async => 1);

      final useCase = CreateCustomerUseCase(mockRepository);
      final id = await useCase(name: 'ACME');
      expect(id, 1);
    });
  });

  group('UpdateCustomerUseCase', () {
    test('delegates to repository', () async {
      when(
        () => mockRepository.updateCustomer(id: 1, name: 'Updated Name'),
      ).thenAnswer((_) async => true);

      final useCase = UpdateCustomerUseCase(mockRepository);
      final result = await useCase(id: 1, name: 'Updated Name');

      expect(result, isTrue);
      verify(
        () => mockRepository.updateCustomer(id: 1, name: 'Updated Name'),
      ).called(1);
    });
  });

  group('DeactivateCustomerUseCase', () {
    test('delegates to repository', () async {
      when(() => mockRepository.deactivateCustomer(1)).thenAnswer((_) async {});

      final useCase = DeactivateCustomerUseCase(mockRepository);
      await useCase(1);

      verify(() => mockRepository.deactivateCustomer(1)).called(1);
    });
  });

  group('DeleteCustomerUseCase', () {
    test('delegates to repository', () async {
      when(() => mockRepository.deleteCustomer(1)).thenAnswer((_) async {});

      final useCase = DeleteCustomerUseCase(mockRepository);
      await useCase(1);

      verify(() => mockRepository.deleteCustomer(1)).called(1);
    });
  });

  group('SearchCustomersUseCase', () {
    test('delegates search to repository', () async {
      when(
        () => mockRepository.searchCustomers('ACME'),
      ).thenAnswer((_) async => [testCustomer]);

      final useCase = SearchCustomersUseCase(mockRepository);
      final result = await useCase('ACME');

      expect(result, [testCustomer]);
      verify(() => mockRepository.searchCustomers('ACME')).called(1);
    });

    test('returns empty for no matches', () async {
      when(
        () => mockRepository.searchCustomers('zzz'),
      ).thenAnswer((_) async => []);

      final useCase = SearchCustomersUseCase(mockRepository);
      final result = await useCase('zzz');

      expect(result, isEmpty);
    });
  });
}
