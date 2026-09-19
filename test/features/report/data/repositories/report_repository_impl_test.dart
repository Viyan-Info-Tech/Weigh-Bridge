import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/report/data/datasources/report_local_datasource.dart';
import 'package:weighbridge/features/report/data/repositories/report_repository_impl.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';

class MockReportLocalDataSource extends Mock implements ReportLocalDataSource {}

void main() {
  final created = DateTime(2026, 9, 18, 10, 30);

  WeighmentReportItem item({
    int id = 1,
    double amount = 0,
    double firstWeightKg = 0,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
  }) {
    return WeighmentReportItem(
      id: id,
      billNumber: 'WB-0000$id',
      createdAt: created,
      vehicleId: 1,
      vehicleNumber: 'TN31CM$id',
      vehicleTypeName: 'Truck',
      partyId: 1,
      partyName: 'Party$id',
      materialId: 1,
      materialName: 'Cement',
      paymentMode: 'cash',
      amount: amount,
      vehicleCharge: 0,
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      rawStatus: secondWeightKg == null ? 'pending' : 'completed',
    );
  }

  group('ReportRepositoryImpl.calculateSummary', () {
    late MockReportLocalDataSource mockSource;
    late ReportRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(const ReportFilter());
    });

    setUp(() {
      mockSource = MockReportLocalDataSource();
      repository = ReportRepositoryImpl(mockSource);
    });

    test('returns all zeros for an empty list', () {
      final summary = repository.calculateSummary([]);
      expect(summary.totalBills, 0);
      expect(summary.totalGrossWeightKg, 0);
      expect(summary.totalRevenue, 0);
      expect(summary.pendingCount, 0);
      expect(summary.completedCount, 0);
    });

    test('sums available weights, revenue and status counts', () {
      final records = [
        item(
          id: 1,
          amount: 250,
          firstWeightKg: 20000,
          secondWeightKg: 5000,
        ),
        item(
          id: 2,
          amount: 300,
          firstWeightKg: 30000,
        ),
      ];

      final summary = repository.calculateSummary(records);
      expect(summary.totalBills, 2);
      expect(summary.totalGrossWeightKg, 50000);
      expect(summary.totalTareWeightKg, 5000);
      expect(summary.totalNetWeightKg, 15000);
      expect(summary.totalRevenue, 550);
      expect(summary.completedCount, 1);
      expect(summary.pendingCount, 1);
    });

    test('skips absent weights instead of adding zero noise', () {
      final records = [
        item(id: 1, firstWeightKg: 0, secondWeightKg: null),
        item(id: 2, firstWeightKg: 10000, secondWeightKg: null),
      ];
      final summary = repository.calculateSummary(records);
      expect(summary.totalGrossWeightKg, 10000);
      expect(summary.totalTareWeightKg, 0);
      expect(summary.totalNetWeightKg, 0);
    });

    test('handles TARE-first records correctly', () {
      final records = [
        item(
          id: 1,
          amount: 100,
          firstWeightKg: 5000,
          firstWeightType: 'TARE',
          secondWeightKg: 20000,
        ),
      ];
      final summary = repository.calculateSummary(records);
      expect(summary.totalGrossWeightKg, 20000);
      expect(summary.totalTareWeightKg, 5000);
      expect(summary.totalNetWeightKg, 15000);
      expect(summary.completedCount, 1);
    });
  });

  group('ReportRepositoryImpl.getReportRecords', () {
    test('delegates the filter to the local data source', () async {
      final mockSource = MockReportLocalDataSource();
      final repository = ReportRepositoryImpl(mockSource);
      const filter = ReportFilter();

      when(() => mockSource.getReportRecords(any())).thenAnswer(
        (_) async => [item(id: 1, secondWeightKg: 5000)],
      );

      final records = await repository.getReportRecords(filter);
      expect(records, hasLength(1));
      verify(() => mockSource.getReportRecords(filter)).called(1);
    });
  });
}