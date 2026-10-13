import 'package:flutter/material.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';

void main() {
  final testCustomer = Customer(
    id: 1,
    name: 'UltraTech Cement',
    mobile: '9876543210',
    isActive: true,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final testMaterial = MaterialItem(
    id: 1,
    name: 'River Sand',
    code: 'M-001',
    isActive: true,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  Widget buildTestForm({
    required Size containerSize,
    String? vehicleNumberError,
    String? materialError,
    String? customerError,
    String? weightError,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: containerSize.width,
            height: containerSize.height,
            child: BillForm(
              billNumber: 'WB-00001',
              customers: [testCustomer],
              materials: [testMaterial],
              selectedCustomer: null,
              selectedMaterial: null,
              grossWeightController: TextEditingController(),
              tareWeightController: TextEditingController(),
              remarksController: TextEditingController(),
              vehicleNumberController: TextEditingController(),
              grossWeightKg: 0,
              tareWeightKg: 0,
              netWeightKg: 0,
              weightUnit: 'Kg',
              selectedType: 'Gross',
              onCustomerChanged: (_) {},
              onVehicleNumberChanged: (_) {},
              onMaterialChanged: (_) {},
              onGrossWeightChanged: (_) {},
              onTareWeightChanged: (_) {},
              onRemarksChanged: (_) {},
              vehicleNumberError: vehicleNumberError,
              materialError: materialError,
              customerError: customerError,
              weightError: weightError,
            ),
          ),
        ),
      ),
    );
  }

  group('BillForm Responsive Layout Tests', () {
    testWidgets(
      'renders without overflow in exact error constraints (w=963, h=485.4) with all errors active',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestForm(
            containerSize: const Size(963.0, 485.4),
            vehicleNumberError: 'Truck number is required.',
            materialError: 'Material code is required.',
            customerError: 'Customer code is required.',
            weightError:
                'Enter or capture at least one weight (Gross or Tare).',
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Truck number is required.'), findsOneWidget);
        expect(find.text('Material code is required.'), findsOneWidget);
        expect(find.text('Customer code is required.'), findsOneWidget);
      },
    );

    testWidgets(
      'renders in compact single column without overflow on narrow width (<760px)',
      (tester) async {
        tester.view.physicalSize = const Size(700, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestForm(
            containerSize: const Size(680.0, 500.0),
            vehicleNumberError: 'Truck number is required.',
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Truck number is required.'), findsOneWidget);
      },
    );

    testWidgets(
      'renders in short height window (<500px) with vertical scroll enabled',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 450);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestForm(
            containerSize: const Size(1100.0, 380.0),
            vehicleNumberError: 'Truck number is required.',
            materialError: 'Material code is required.',
            customerError: 'Customer code is required.',
            weightError:
                'Enter or capture at least one weight (Gross or Tare).',
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        expect(find.byType(Scrollbar), findsOneWidget);
      },
    );
  });
}
