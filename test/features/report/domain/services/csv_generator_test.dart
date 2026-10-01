import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/services/csv_generator.dart';

void main() {
  const generator = CsvGenerator();

  WeighmentReportItem item({
    required String billNumber,
    int id = 1,
    DateTime? createdAt,
    String vehicleNumber = 'TN31CM2026',
    String customerName = 'ACME Traders',
    String materialName = 'Cement',
    double firstWeightKg = 20000,
    String firstWeightType = 'GROSS',
    double? secondWeightKg = 5000,
    double amount = 125,
    String weightUnit = 'ton',
    double vehicleCharge = 125,
  }) {
    return WeighmentReportItem(
      id: id,
      billNumber: billNumber,
      createdAt: createdAt ?? DateTime(2026, 9, 18, 10, 30),
      vehicleNumber: vehicleNumber,
      customerId: 1,
      customerName: customerName,
      materialId: 1,
      materialName: materialName,
      paymentMode: 'cash',
      amount: amount,
      vehicleCharge: vehicleCharge,
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      weightUnit: weightUnit,
    );
  }

  group('generateSuggestedFileName', () {
    test('single-day range uses one date', () {
      final name = generator.generateSuggestedFileName(const ReportFilter());
      final date = DateTime.now();
      final expected =
          'weighment_report_'
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}.csv';
      expect(name, expected);
    });

    test('multi-day custom range uses from and to dates', () {
      final name = generator.generateSuggestedFileName(
        ReportFilter(
          datePreset: DateRangePreset.custom,
          customStartDate: DateTime(2026, 9, 1),
          customEndDate: DateTime(2026, 9, 13),
        ),
      );
      expect(name, 'weighment_report_2026-09-01_to_2026-09-13.csv');
    });
  });

  group('generateCsvString', () {
    test('starts with UTF-8 BOM and correct header', () {
      final csv = generator.generateCsvString([]);
      expect(csv.startsWith('\uFEFF'), isTrue);

      final lines = csv.split('\n');
      expect(
        lines.first,
        contains(
          'Bill No,Date & Time,Vehicle,Customer,Material,Gross Weight,'
          'Tare Weight,Net Weight,Weight Unit,Amount,Status',
        ),
      );
    });

    test('converts ton-based weights to tons with 3 decimals', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-001', firstWeightKg: 20000, secondWeightKg: 5000),
      ]);
      expect(csv, contains('20.000 ton'));
      expect(csv, contains('5.000 ton'));
      expect(csv, contains('15.000 ton'));
    });

    test('uses 0 decimals for kg-based weights', () {
      final csv = generator.generateCsvString([
        item(
          billNumber: 'WB-001',
          weightUnit: 'kg',
          firstWeightKg: 20000,
          secondWeightKg: 5000,
        ),
      ]);
      expect(csv, contains('20000 kg'));
      expect(csv, contains('5000 kg'));
      expect(csv, contains('15000 kg'));
    });

    test('leaves missing weights empty', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-002', firstWeightKg: 20000, secondWeightKg: null),
      ]);
      expect(csv, contains('20.000 ton,,'));
    });

    test('marks every record as Completed', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-001', firstWeightKg: 20000, secondWeightKg: 5000),
        item(billNumber: 'WB-002', firstWeightKg: 20000, secondWeightKg: null),
      ]);
      expect(csv, contains('Completed'));
      expect(csv, isNot(contains('Pending')));
      expect(csv.split('Completed').length - 1, 2);
    });

    test('marks records without any captured weight as Incomplete', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-001', firstWeightKg: 20000, secondWeightKg: 5000),
        item(billNumber: 'WB-005', firstWeightKg: 0, secondWeightKg: null),
      ]);
      expect(csv.split('Completed').length - 1, 1);
      expect(csv.split('Incomplete').length - 1, 1);
      expect(csv, isNot(contains('Pending')));
    });

    test('quotes fields containing commas or quotes', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-003', customerName: 'Kumar, Sons & "Co"'),
      ]);
      expect(csv, contains('"Kumar, Sons & ""Co"""'));
    });
  });

  group('generateCsvBytes', () {
    test('encodes the CSV as UTF-8 bytes', () {
      final bytes = generator.generateCsvBytes([item(billNumber: 'WB-001')]);
      final decoded = utf8.decode(bytes);
      expect(decoded, contains('WB-001'));
      expect(bytes, isNotEmpty);
    });
  });
}
