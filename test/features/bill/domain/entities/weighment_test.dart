import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';

void main() {
  final base = DateTime(2026, 9, 18, 10, 30);

  Weighment build({
    String status = 'pending',
    double? firstWeightKg,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
    double? netWeightKg,
  }) {
    return Weighment(
      id: 1,
      billNumber: 'WB-00001',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'cash',
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      netWeightKg: netWeightKg,
      vehicleCharge: 0,
      amount: 0,
      status: status,
      createdAt: base,
      updatedAt: base,
    );
  }

  group('Weighment construction', () {
    test('uses default firstWeightType, status and weightUnit', () {
      final w = build();
      expect(w.firstWeightType, 'GROSS');
      expect(w.status, 'pending');
      expect(w.weightUnit, 'ton');
    });

    test('maps grossWeightKg into firstWeightKg when firstWeightType is TARE',
        () {
      final w = Weighment(
        id: 1,
        billNumber: 'WB-00001',
        partyId: 1,
        vehicleId: 1,
        materialId: 1,
        paymentMode: 'cash',
        firstWeightType: 'TARE',
        tareWeightKg: 5000,
        vehicleCharge: 0,
        amount: 0,
        createdAt: base,
        updatedAt: base,
      );
      expect(w.firstWeightKg, 5000);
      expect(w.explicitNetWeightKg, isNull);
    });
  });

  group('isCompleted / isPending', () {
    test('returns true when status is completed', () {
      expect(build(status: 'completed').isCompleted, isTrue);
      expect(build(status: 'completed').isPending, isFalse);
    });

    test('returns true from matching weights even when status is pending', () {
      final w = build(
        status: 'pending',
        firstWeightKg: 20000,
        secondWeightKg: 5000,
      );
      expect(w.isCompleted, isTrue);
      expect(w.isPending, isFalse);
    });

    test('returns false for a one-stage weighment', () {
      final w = build(status: 'pending', firstWeightKg: 20000);
      expect(w.isCompleted, isFalse);
      expect(w.isPending, isTrue);
    });
  });

  group('grossWeightKg', () {
    test('GROSS type returns firstWeight when positive', () {
      expect(build(firstWeightKg: 20000).grossWeightKg, 20000);
    });

    test('GROSS type returns null when firstWeight is zero', () {
      expect(build(firstWeightKg: 0).grossWeightKg, isNull);
    });

    test('TARE type returns secondWeight when positive', () {
      final w = build(
        firstWeightType: 'TARE',
        firstWeightKg: 5000,
        secondWeightKg: 20000,
      );
      expect(w.grossWeightKg, 20000);
    });

    test('TARE type returns null without a second weight', () {
      final w = build(firstWeightType: 'TARE', firstWeightKg: 5000);
      expect(w.grossWeightKg, isNull);
    });
  });

  group('tareWeightKg', () {
    test('TARE type returns firstWeight when positive', () {
      final w = build(
        firstWeightType: 'TARE',
        firstWeightKg: 5000,
        secondWeightKg: 20000,
      );
      expect(w.tareWeightKg, 5000);
    });

    test('GROSS type returns secondWeight when positive', () {
      final w = build(firstWeightKg: 20000, secondWeightKg: 5000);
      expect(w.tareWeightKg, 5000);
    });
  });

  group('netWeightKg', () {
    test('honors an explicit net weight', () {
      final w = build(
        firstWeightKg: 20000,
        secondWeightKg: 5000,
        netWeightKg: 15000,
      );
      expect(w.netWeightKg, 15000);
    });

    test('computes absolute difference of gross and tare', () {
      final w = build(firstWeightKg: 20000, secondWeightKg: 5000);
      expect(w.netWeightKg, 15000);
    });

    test('is null when only one weight is available', () {
      final w = build(firstWeightKg: 20000);
      expect(w.netWeightKg, isNull);
    });
  });

  test('equality is based on business fields', () {
    expect(build(), equals(build()));
    expect(build().hashCode, equals(build().hashCode));
    expect(build(firstWeightKg: 1), isNot(equals(build())));
  });
}