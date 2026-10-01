import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/quick_add_customer_dialog.dart';

import 'package:weighbridge/features/customer/domain/entities/customer.dart';

void main() {
  group('QuickAddCustomerDialog Widget Tests', () {
    testWidgets('renders beautifully and validates required fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddCustomerDialog.show(
                  context,
                  onSave: (name, contact) async => null,
                ),
                child: const Text('Open Customer'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Add Customer'), findsOneWidget);
      expect(find.text('Customer Name *'), findsOneWidget);
      expect(find.text('Contact person name *'), findsOneWidget);

      await tester.tap(find.text('Save Customer'));
      await tester.pumpAndSettle();

      expect(find.text('Customer name is required'), findsOneWidget);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('filters input and successfully saves customer', (
      tester,
    ) async {
      final createdCustomer = Customer(
        id: 1,
        name: 'JSW Steel',
        contactPerson: 'John Doe',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Customer? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await QuickAddCustomerDialog.show(
                    context,
                    onSave: (name, contact) async => createdCustomer,
                  );
                },
                child: const Text('Open Customer'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Customer'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'JSW Steel');
      // Enter text with numbers and symbols to verify FilteringTextInputFormatter blocks them
      await tester.enterText(find.byType(TextFormField).at(1), 'John123 Doe@#');
      expect(find.text('John Doe'), findsOneWidget);

      await tester.tap(find.text('Save Customer'));
      await tester.pumpAndSettle();

      expect(result, equals(createdCustomer));
      expect(find.byType(QuickAddCustomerDialog), findsNothing);
    });
  });
}
