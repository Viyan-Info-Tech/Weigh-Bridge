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
    String? material,
    String? description,
    String? containerNo,
    String? remarks,
    double firstWeightKg = 20000,
    String firstWeightType = 'GROSS',
    double? secondWeightKg = 5000,
    String weightUnit = 'ton',
  }) {
    return WeighmentReportItem(
      id: id,
      billNumber: billNumber,
      createdAt: createdAt ?? DateTime(2026, 9, 18, 10, 30),
      vehicleNumber: vehicleNumber,
      material: material,
      description: description,
      containerNo: containerNo,
      remarks: remarks,
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
          'Bill No,Date & Time,Vehicle,Material,Description,Container No,Gross Weight,'
          'Tare Weight,Net Weight,Status',
        ),
      );
      expect(csv, isNot(contains('Weight Unit')));
      expect(csv, isNot(contains('Customer')));
      expect(csv, contains('Material'));
      expect(csv, contains('Description'));
      expect(csv, contains('Container No'));
    });

    test(
      'header and rows contain no Weight Unit column and align correctly',
      () {
        final csv = generator.generateCsvString([
          item(
            billNumber: 'WB-001',
            firstWeightKg: 20000,
            secondWeightKg: 5000,
          ),
        ]);
        expect(csv, isNot(contains('Weight Unit')));

        final lines = csv.trim().split('\n');
        final headerColumns = lines.first.replaceFirst('\uFEFF', '').split(',');
        expect(headerColumns, [
          'Bill No',
          'Date & Time',
          'Vehicle',
          'Material',
          'Description',
          'Container No',
          'Gross Weight',
          'Tare Weight',
          'Net Weight',
          'Status',
        ]);

        final row = lines[1];
        expect(row, isNot(contains('Weight Unit')));
        expect(row, contains('WB-001'));
        expect(row, contains('TN31CM2026'));
        expect(row, contains('20.000 ton'));
        expect(row, contains('5.000 ton'));
        expect(row, contains('15.000 ton,COMPLETED'));
        expect(row.endsWith('COMPLETED'), isTrue);
      },
    );

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

    test('includes vehicle, material, description, and container columns', () {
      final csv = generator.generateCsvString([
        item(
          billNumber: 'WB-00007',
          vehicleNumber: 'TN31PS2002',
          material: 'Sand',
          description: 'CDM',
          containerNo: '12',
        ),
      ]);
      expect(csv, contains('WB-00007'));
      expect(csv, contains('TN31PS2002,Sand,CDM,12'));
    });

    test(
      'handles null material, description, and container as empty values',
      () {
        final csv = generator.generateCsvString([
          item(
            billNumber: 'WB-00008',
            vehicleNumber: 'TN31PS2003',
            material: null,
            description: null,
            containerNo: null,
            remarks: null,
          ),
        ]);
        expect(csv, contains('TN31PS2003,,,,'));
      },
    );

    test('falls back to remarks when containerNo is omitted', () {
      final csv = generator.generateCsvString([
        item(
          billNumber: 'WB-00009',
          vehicleNumber: 'TN31PS2004',
          material: 'Gravel',
          description: 'Site A',
          remarks: 'CONT-99',
        ),
      ]);
      expect(csv, contains('TN31PS2004,Gravel,Site A,CONT-99'));
    });

    test('leaves missing weights empty', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-002', firstWeightKg: 20000, secondWeightKg: null),
      ]);
      expect(csv, contains('20.000 ton,,'));
    });

    test('marks every completed record as COMPLETED', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-001', firstWeightKg: 20000, secondWeightKg: 5000),
        item(billNumber: 'WB-002', firstWeightKg: 20000, secondWeightKg: null),
      ]);
      expect(csv, contains('COMPLETED'));
      expect(csv, isNot(contains('Pending')));
      expect(csv.split('COMPLETED').length - 1, 2);
    });

    test('marks records without any captured weight as INCOMPLETE', () {
      final csv = generator.generateCsvString([
        item(billNumber: 'WB-001', firstWeightKg: 20000, secondWeightKg: 5000),
        item(billNumber: 'WB-005', firstWeightKg: 0, secondWeightKg: null),
      ]);
      expect(csv.split('COMPLETED').length - 1, 1);
      expect(csv.split('INCOMPLETE').length - 1, 1);
      expect(csv, isNot(contains('Pending')));
    });

    test('quotes fields containing commas or quotes', () {
      final csv = generator.generateCsvString([
        item(
          billNumber: 'WB-003',
          vehicleNumber: 'TN31, "X"',
          material: 'Sand, Fine',
          description: 'Item "Special"',
          containerNo: 'C,12',
        ),
      ]);
      expect(csv, contains('"TN31, ""X"""'));
      expect(csv, contains('"Sand, Fine"'));
      expect(csv, contains('"Item ""Special"""'));
      expect(csv, contains('"C,12"'));
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
