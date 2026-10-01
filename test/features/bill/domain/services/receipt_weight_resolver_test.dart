import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/services/receipt_weight_resolver.dart';

void main() {
  const resolver = ReceiptWeightResolver();

  Weighment weighment({
    double firstWeightKg = 0,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
  }) {
    return Weighment(
      id: 1,
      billNumber: 'WB-00001',
      customerId: 1,
      vehicleNumber: 'TN31CM2026',
      materialId: 1,
      paymentMode: 'Cash',
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      grossWeightKg: grossWeightKg,
      tareWeightKg: tareWeightKg,
      netWeightKg: netWeightKg,
      vehicleCharge: 0,
      amount: 0,
      createdAt: DateTime(2026, 9, 18),
      updatedAt: DateTime(2026, 9, 18),
    );
  }

  group('ReceiptWeightResolver', () {
    test('gross-only weighment keeps tare and net null', () {
      final weights = resolver.resolve(
        weighment(firstWeightKg: 20000, firstWeightType: 'GROSS'),
      );

      expect(weights.grossKg, 20000);
      expect(weights.tareKg, isNull);
      expect(weights.netKg, isNull);
    });

    test('tare-only weighment keeps gross and net null', () {
      final weights = resolver.resolve(
        weighment(firstWeightKg: 5000, firstWeightType: 'TARE'),
      );

      expect(weights.grossKg, isNull);
      expect(weights.tareKg, 5000);
      expect(weights.netKg, isNull);
    });

    test('both weights present resolves net as their difference', () {
      final weights = resolver.resolve(
        weighment(firstWeightKg: 20000, secondWeightKg: 5000),
      );

      expect(weights.grossKg, 20000);
      expect(weights.tareKg, 5000);
      expect(weights.netKg, 15000);
    });

    test('weighment without weights resolves to all null', () {
      final weights = resolver.resolve(weighment());

      expect(weights.grossKg, isNull);
      expect(weights.tareKg, isNull);
      expect(weights.netKg, isNull);
    });

    test('derives missing gross from tare plus explicit net', () {
      final weights = resolver.resolve(
        weighment(
          firstWeightType: 'TARE',
          firstWeightKg: 5000,
          netWeightKg: 15000,
        ),
      );

      expect(weights.tareKg, 5000);
      expect(weights.netKg, 15000);
      expect(weights.grossKg, 20000);
    });
  });
}
