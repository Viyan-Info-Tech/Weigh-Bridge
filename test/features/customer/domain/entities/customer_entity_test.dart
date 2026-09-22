import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';

void main() {
  final now = DateTime(2026, 9, 21, 10, 30);

  Customer buildCustomer({
    int id = 1,
    String name = 'Test Customer',
    String? contactPerson = 'John',
    String? mobile = '9876543210',
    String? email = 'test@example.com',
    String? address = 'Chennai',
    String? gstNumber = '33ABCDE1234F1Z5',
    String? city = 'Chennai',
    String? state = 'Tamil Nadu',
    bool isActive = true,
  }) {
    return Customer(
      id: id,
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Customer entity', () {
    test('constructs with required fields only', () {
      final customer = Customer(
        id: 1,
        name: 'Minimal Customer',
        createdAt: now,
        updatedAt: now,
      );
      expect(customer.id, 1);
      expect(customer.name, 'Minimal Customer');
      expect(customer.contactPerson, isNull);
      expect(customer.mobile, isNull);
      expect(customer.email, isNull);
      expect(customer.address, isNull);
      expect(customer.gstNumber, isNull);
      expect(customer.city, isNull);
      expect(customer.state, isNull);
      expect(customer.isActive, isTrue);
    });

    test('constructs with all fields', () {
      final customer = buildCustomer();
      expect(customer.id, 1);
      expect(customer.name, 'Test Customer');
      expect(customer.contactPerson, 'John');
      expect(customer.mobile, '9876543210');
      expect(customer.email, 'test@example.com');
      expect(customer.address, 'Chennai');
      expect(customer.gstNumber, '33ABCDE1234F1Z5');
      expect(customer.city, 'Chennai');
      expect(customer.state, 'Tamil Nadu');
      expect(customer.isActive, isTrue);
      expect(customer.createdAt, now);
      expect(customer.updatedAt, now);
    });

    test('equality is based on all props', () {
      final a = buildCustomer();
      final b = buildCustomer();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different id makes customers unequal', () {
      final a = buildCustomer(id: 1);
      final b = buildCustomer(id: 2);
      expect(a, isNot(equals(b)));
    });

    test('different name makes customers unequal', () {
      final a = buildCustomer(name: 'Alpha');
      final b = buildCustomer(name: 'Beta');
      expect(a, isNot(equals(b)));
    });

    test('different isActive makes customers unequal', () {
      final a = buildCustomer(isActive: true);
      final b = buildCustomer(isActive: false);
      expect(a, isNot(equals(b)));
    });

    test('props includes all fields', () {
      final customer = buildCustomer();
      expect(customer.props, [
        1,
        'Test Customer',
        'John',
        '9876543210',
        'test@example.com',
        'Chennai',
        '33ABCDE1234F1Z5',
        'Chennai',
        'Tamil Nadu',
        true,
        now,
        now,
      ]);
    });

    test('Tamil text in name is preserved', () {
      final customer = buildCustomer(name: 'தமிழ் நிறுவனம்');
      expect(customer.name, 'தமிழ் நிறுவனம்');
    });

    test('special characters in fields are preserved', () {
      final customer = buildCustomer(
        name: 'Kumar, Sons & "Co"',
        gstNumber: '33ABCDE@1234#F1Z5',
        address: '123 Main St, Near Temple',
      );
      expect(customer.name, 'Kumar, Sons & "Co"');
      expect(customer.gstNumber, '33ABCDE@1234#F1Z5');
      expect(customer.address, '123 Main St, Near Temple');
    });

    test('empty string fields are valid', () {
      final customer = buildCustomer(name: '', mobile: '', email: '');
      expect(customer.name, '');
      expect(customer.mobile, '');
      expect(customer.email, '');
    });

    test('long strings are accepted', () {
      final longName = 'A' * 200;
      final customer = buildCustomer(name: longName);
      expect(customer.name.length, 200);
    });

    test('inactive customer defaults are correct', () {
      final customer = buildCustomer(isActive: false);
      expect(customer.isActive, isFalse);
    });
  });
}
