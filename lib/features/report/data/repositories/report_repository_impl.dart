import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;

  ReportRepositoryImpl(this._localDataSource);

  @override
  Future<List<WeighmentReportItem>> getReportRecords(
    ReportFilter filter, {
    int? limit,
    int offset = 0,
  }) {
    return _localDataSource.getReportRecords(
      filter,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> countReportRecords(ReportFilter filter) {
    return _localDataSource.countReportRecords(filter);
  }

  @override
  Future<ReportSummary> summarizeReportRecords(ReportFilter filter) {
    return _localDataSource.summarizeReportRecords(filter);
  }
}
