import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/report/data/datasources/report_local_datasource.dart';
import 'package:weighbridge/features/report/data/repositories/report_repository_impl.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';

class MockReportLocalDataSource extends Mock implements ReportLocalDataSource {}

void main() {
  final created = DateTime(2026, 9, 18, 10, 30);

  WeighmentReportItem item({
    int id = 1,
    double firstWeightKg = 0,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
  }) {
    return WeighmentReportItem(
      id: id,
      billNumber: 'WB-0000$id',
      createdAt: created,
      vehicleNumber: 'TN31CM$id',
      customerId: 1,
      customerName: 'Customer$id',
      materialId: 1,
      materialName: 'Cement',
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
    );
  }

  group('ReportRepositoryImpl', () {
    late MockReportLocalDataSource mockSource;
    late ReportRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(const ReportFilter());
    });

    setUp(() {
      mockSource = MockReportLocalDataSource();
      repository = ReportRepositoryImpl(mockSource);
    });

    test('getReportRecords delegates the filter to the data source', () async {
      const filter = ReportFilter();

      when(
        () => mockSource.getReportRecords(any()),
      ).thenAnswer((_) async => [item(id: 1, secondWeightKg: 5000)]);

      final records = await repository.getReportRecords(filter);
      expect(records, hasLength(1));
      verify(() => mockSource.getReportRecords(filter)).called(1);
    });

    test('getReportRecords forwards the page window', () async {
      const filter = ReportFilter();
      when(
        () => mockSource.getReportRecords(
          any(),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => []);

      await repository.getReportRecords(filter, limit: 50, offset: 100);

      verify(
        () => mockSource.getReportRecords(filter, limit: 50, offset: 100),
      ).called(1);
    });

    test('countReportRecords delegates to the data source', () async {
      const filter = ReportFilter();
      when(
        () => mockSource.countReportRecords(any()),
      ).thenAnswer((_) async => 7);

      expect(await repository.countReportRecords(filter), 7);
      verify(() => mockSource.countReportRecords(filter)).called(1);
    });

    test('summarizeReportRecords delegates to the data source', () async {
      const filter = ReportFilter();
      when(() => mockSource.summarizeReportRecords(any())).thenAnswer(
        (_) async =>
            const ReportSummary(totalBills: 3, totalGrossWeightKg: 900),
      );

      final summary = await repository.summarizeReportRecords(filter);
      expect(summary.totalBills, 3);
      expect(summary.totalGrossWeightKg, 900);
      verify(() => mockSource.summarizeReportRecords(filter)).called(1);
    });
  });
}
