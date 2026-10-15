import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';

void main() {
  final created = DateTime(2026, 9, 18, 10, 30);

  WeighmentReportItem build({
    double firstWeightKg = 0,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
    String? material,
    String? description,
    String? containerNo,
    String? remarks,
  }) {
    return WeighmentReportItem(
      id: 1,
      billNumber: 'WB-00001',
      createdAt: created,
      vehicleNumber: 'TN31CM2026',
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      material: material,
      description: description,
      containerNo: containerNo,
      remarks: remarks,
    );
  }

  group('material, description, and containerNo', () {
    test('stores material, description, and containerNo', () {
      final item = build(
        material: 'Sand',
        description: 'CDM',
        containerNo: '12',
      );
      expect(item.material, 'Sand');
      expect(item.description, 'CDM');
      expect(item.containerNo, '12');
      expect(item.effectiveContainerNo, '12');
    });

    test('effectiveContainerNo falls back to remarks when containerNo is omitted', () {
      final item = build(
        remarks: 'CONT-88',
      );
      expect(item.containerNo, 'CONT-88');
      expect(item.effectiveContainerNo, 'CONT-88');
    });

    test('preserves null values when not provided', () {
      final item = build();
      expect(item.material, isNull);
      expect(item.description, isNull);
      expect(item.containerNo, isNull);
      expect(item.effectiveContainerNo, isNull);
    });
  });

  group('grossWeightKg / tareWeightKg', () {
    test('GROSS type: first weight is gross, second is tare', () {
      final item = build(firstWeightKg: 20000, secondWeightKg: 5000);
      expect(item.grossWeightKg, 20000);
      expect(item.tareWeightKg, 5000);
    });

    test('TARE type: first weight is tare, second is gross', () {
      final item = build(
        firstWeightKg: 5000,
        firstWeightType: 'TARE',
        secondWeightKg: 20000,
      );
      expect(item.grossWeightKg, 20000);
      expect(item.tareWeightKg, 5000);
    });

    test('zero weights are treated as absent', () {
      final item = build(firstWeightKg: 0);
      expect(item.grossWeightKg, isNull);
      expect(item.tareWeightKg, isNull);
    });
  });

  group('netWeightKg', () {
    test('is null when both weights are not available', () {
      expect(build(firstWeightKg: 20000).netWeightKg, isNull);
    });

    test('computes absolute difference between gross and tare', () {
      final item = build(firstWeightKg: 20000, secondWeightKg: 5000);
      expect(item.netWeightKg, 15000);
    });
  });

  group('isCompleted', () {
    test('returns true when both weights are present', () {
      final item = build(firstWeightKg: 20000, secondWeightKg: 5000);
      expect(item.isCompleted, isTrue);
    });

    test('returns true when only a gross weight is present', () {
      final item = build(firstWeightKg: 20000);
      expect(item.isCompleted, isTrue);
    });

    test('returns true when only a tare weight is present', () {
      final item = build(firstWeightKg: 5000, firstWeightType: 'TARE');
      expect(item.isCompleted, isTrue);
    });

    test('returns false when no weights are present', () {
      expect(build().isCompleted, isFalse);
    });
  });
}
