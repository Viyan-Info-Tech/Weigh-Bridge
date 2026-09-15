import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/quick_add_party_dialog.dart';
import 'package:weighbridge/features/bill/presentation/widgets/quick_add_vehicle_dialog.dart';
import 'package:weighbridge/features/bill/presentation/widgets/quick_add_vehicle_type_dialog.dart';
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/vehicle_type/domain/entities/vehicle_type.dart';

void main() {
  group('QuickAddPartyDialog Widget Tests', () {
    testWidgets('renders beautifully and validates required fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddPartyDialog.show(
                  context,
                  onSave: (name, contact) async => null,
                ),
                child: const Text('Open Party'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Party'));
      await tester.pumpAndSettle();

      expect(find.text('Add Party'), findsOneWidget);
      expect(find.text('Party Name *'), findsOneWidget);
      expect(find.text('Contact person name *'), findsOneWidget);

      await tester.tap(find.text('Save Party'));
      await tester.pumpAndSettle();

      expect(find.text('Party name is required'), findsOneWidget);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('filters input and successfully saves party', (tester) async {
      final createdParty = Party(
        id: 1,
        name: 'JSW Steel',
        contactPerson: 'John Doe',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Party? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await QuickAddPartyDialog.show(
                    context,
                    onSave: (name, contact) async => createdParty,
                  );
                },
                child: const Text('Open Party'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Party'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'JSW Steel');
      // Enter text with numbers and symbols to verify FilteringTextInputFormatter blocks them
      await tester.enterText(find.byType(TextFormField).at(1), 'John123 Doe@#');
      expect(find.text('John Doe'), findsOneWidget);

      await tester.tap(find.text('Save Party'));
      await tester.pumpAndSettle();

      expect(result, equals(createdParty));
      expect(find.byType(QuickAddPartyDialog), findsNothing);
    });
  });

  group('QuickAddVehicleTypeDialog Widget Tests', () {
    testWidgets(
      'renders vehicle type dialog with currency prefix and validates',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => QuickAddVehicleTypeDialog.show(
                    context,
                    onSave: (name, empty, load) async => null,
                  ),
                  child: const Text('Open Type'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Type'));
        await tester.pumpAndSettle();

        expect(find.text('Add Vehicle Type'), findsOneWidget);
        expect(find.text('Name *'), findsOneWidget);
        expect(find.text('Empty Price'), findsOneWidget);
        expect(find.text('Load Price'), findsOneWidget);
        expect(find.text('₹ '), findsNWidgets(2));

        await tester.tap(find.text('Save Type'));
        await tester.pumpAndSettle();

        expect(find.text('Vehicle type name is required'), findsOneWidget);
      },
    );
  });

  group('QuickAddVehicleDialog Widget Tests', () {
    testWidgets('renders vehicle dialog and enforces vehicle type selection', (
      tester,
    ) async {
      final types = [
        VehicleType(
          id: 1,
          name: '10 Wheeler',
          loadPrice: 400,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddVehicleDialog.show(
                  context: context,
                  vehicleTypes: types,
                  onSave: (vehicleNumber, typeId) {},
                  onAddVehicleType: (n, e, l) async => null,
                ),
                child: const Text('Open Vehicle'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Add Vehicle'), findsOneWidget);
      expect(find.text('Vehicle Number *'), findsOneWidget);
      expect(find.text('Vehicle Type *'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'MH12AB1234');
      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Vehicle type is required'), findsOneWidget);
    });

    testWidgets('rejects invalid vehicle number before saving', (tester) async {
      final types = [
        VehicleType(
          id: 1,
          name: 'Truck',
          loadPrice: 400,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => QuickAddVehicleDialog.show(
                  context: context,
                  vehicleTypes: types,
                  onSave: (vehicleNumber, typeId) => saved = true,
                  onAddVehicleType: (n, e, l) async => null,
                ),
                child: const Text('Open Vehicle'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Vehicle'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'ASDFGHK345678234567890SXCVBNM',
      );
      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid vehicle registration number'),
        findsOneWidget,
      );
      expect(saved, isFalse);
    });
  });
}
