import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';

void main() {
  final base = DateTime(2026, 9, 18, 10, 30);

  Weighment build({
    double? firstWeightKg,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
    double? netWeightKg,
  }) {
    return Weighment(
      id: 1,
      billNumber: 'WB-00001',
      customerId: 1,
      vehicleNumber: 'TN31AB1234',
      materialId: 1,
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      netWeightKg: netWeightKg,
      createdAt: base,
      updatedAt: base,
    );
  }

  group('Weighment construction', () {
    test('uses default firstWeightType and weightUnit', () {
      final w = build();
      expect(w.firstWeightType, 'GROSS');
      expect(w.weightUnit, 'ton');
    });

    test(
      'maps grossWeightKg into firstWeightKg when firstWeightType is TARE',
      () {
        final w = Weighment(
          id: 1,
          billNumber: 'WB-00001',
          customerId: 1,
          vehicleNumber: 'TN31AB1234',
          materialId: 1,
          firstWeightType: 'TARE',
          tareWeightKg: 5000,
          createdAt: base,
          updatedAt: base,
        );
        expect(w.firstWeightKg, 5000);
        expect(w.explicitNetWeightKg, isNull);
      },
    );
  });

  group('isCompleted', () {
    test('returns true when both weights are present', () {
      expect(
        build(firstWeightKg: 20000, secondWeightKg: 5000).isCompleted,
        isTrue,
      );
    });

    test('returns true for a one-stage weighment with only Gross', () {
      final w = build(firstWeightKg: 20000);
      expect(w.isCompleted, isTrue);
    });

    test('returns true for a one-stage weighment with only Tare', () {
      final w = build(firstWeightType: 'TARE', firstWeightKg: 5000);
      expect(w.isCompleted, isTrue);
    });

    test('returns false when neither weight is present', () {
      expect(build().isCompleted, isFalse);
      expect(build(firstWeightKg: 0, secondWeightKg: 0).isCompleted, isFalse);
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
