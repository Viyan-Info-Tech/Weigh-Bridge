import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;

  ReportRepositoryImpl(this._localDataSource);

  @override
  Future<List<WeighmentReportItem>> getReportRecords(ReportFilter filter) {
    return _localDataSource.getReportRecords(filter);
  }

  @override
  ReportSummary calculateSummary(List<WeighmentReportItem> records) {
    double totalGross = 0;
    double totalTare = 0;
    double totalNet = 0;
    double totalRev = 0;
    int pending = 0;
    int completed = 0;

    for (final item in records) {
      if (item.grossWeightKg != null) {
        totalGross += item.grossWeightKg!;
      }
      if (item.tareWeightKg != null) {
        totalTare += item.tareWeightKg!;
      }
      if (item.netWeightKg != null) {
        totalNet += item.netWeightKg!;
      }
      totalRev += item.amount;

      if (item.isCompleted) {
        completed++;
      } else {
        pending++;
      }
    }

    return ReportSummary(
      totalBills: records.length,
      totalGrossWeightKg: totalGross,
      totalTareWeightKg: totalTare,
      totalNetWeightKg: totalNet,
      totalRevenue: totalRev,
      pendingCount: pending,
      completedCount: completed,
    );
  }
}
