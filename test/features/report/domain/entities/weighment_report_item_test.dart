import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';

void main() {
  final created = DateTime(2026, 9, 18, 10, 30);

  WeighmentReportItem build({
    double firstWeightKg = 0,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
    String rawStatus = 'completed',
  }) {
    return WeighmentReportItem(
      id: 1,
      billNumber: 'WB-00001',
      createdAt: created,
      vehicleId: 1,
      vehicleNumber: 'TN31CM2026',
      vehicleTypeName: 'Truck',
      partyId: 1,
      partyName: 'Party',
      materialId: 1,
      materialName: 'Cement',
      paymentMode: 'cash',
      amount: 0,
      vehicleCharge: 0,
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      rawStatus: rawStatus,
    );
  }

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

  group('displayStatus', () {
    test('COMPLETED when both weights are present', () {
      final item = build(firstWeightKg: 20000, secondWeightKg: 5000);
      expect(item.displayStatus, 'COMPLETED');
      expect(item.isCompleted, isTrue);
      expect(item.isPending, isFalse);
    });

    test('PENDING when only a first weight is present', () {
      final item = build(firstWeightKg: 20000);
      expect(item.displayStatus, 'PENDING');
      expect(item.isCompleted, isFalse);
      expect(item.isPending, isTrue);
    });

    test('PENDING when no weights are present', () {
      expect(build().displayStatus, 'PENDING');
    });
  });
}