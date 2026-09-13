import '../entities/report_filter.dart';
import '../entities/report_summary.dart';
import '../entities/weighment_report_item.dart';

abstract class ReportRepository {
  Future<List<WeighmentReportItem>> getReportRecords(ReportFilter filter);
  ReportSummary calculateSummary(List<WeighmentReportItem> records);
}
