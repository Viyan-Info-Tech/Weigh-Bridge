import '../entities/report_filter.dart';
import '../entities/report_summary.dart';
import '../entities/weighment_report_item.dart';

abstract class ReportRepository {
  /// Returns one page of records matching [filter], newest first.
  ///
  /// Omit [limit] to get the whole result set; that is reserved for exports.
  /// Anything rendered on screen must pass a [limit] so memory stays bounded
  /// regardless of how many weighments match.
  Future<List<WeighmentReportItem>> getReportRecords(
    ReportFilter filter, {
    int? limit,
    int offset = 0,
  });

  /// Counts every record matching [filter], ignoring paging.
  Future<int> countReportRecords(ReportFilter filter);

  /// Totals for every record matching [filter], not just the current page.
  Future<ReportSummary> summarizeReportRecords(ReportFilter filter);
}