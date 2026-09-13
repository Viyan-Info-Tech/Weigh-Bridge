import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../entities/report_filter.dart';
import '../entities/weighment_report_item.dart';

class CsvGenerator {
  const CsvGenerator();

  /// Production-grade filename generator based on report filters:
  /// e.g. weighment_report_2026-09-13.csv
  /// e.g. weighment_report_pending_2026-09-13.csv
  /// e.g. weighment_report_2026-09-01_to_2026-09-13.csv
  String generateSuggestedFileName(ReportFilter filter) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    String statusPart = '';
    if (filter.status != 'all') {
      statusPart = '_${filter.status.toLowerCase()}';
    }

    final startDate = filter.effectiveStartDate;
    final endDate = filter.effectiveEndDate;

    final isSameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    String datePart;
    if (isSameDay) {
      datePart = dateFormat.format(startDate);
    } else {
      datePart = '${dateFormat.format(startDate)}_to_${dateFormat.format(endDate)}';
    }

    return 'weighment_report${statusPart}_$datePart.csv';
  }

  /// Generates clean tabular CSV data with UTF-8 BOM for Excel compatibility.
  String generateCsvString(List<WeighmentReportItem> records) {
    final buffer = StringBuffer();
    // Prepend UTF-8 Byte Order Mark (BOM) for Excel
    buffer.write('\uFEFF');

    // Clean, standard CSV Header
    buffer.writeln(
      'Bill No,Date & Time,Vehicle,Party,Material,Gross Weight,Tare Weight,Net Weight,Amount,Status',
    );

    final dateTimeFormat = DateFormat('dd/MM/yyyy hh:mm a');

    for (final item in records) {
      final dateTimeStr = dateTimeFormat.format(item.createdAt);
      // Represent empty weight values as empty strings in CSV so cells are clean
      final grossStr = item.grossWeightKg != null
          ? '${item.grossWeightKg!.toStringAsFixed(0)} kg'
          : '';
      final tareStr = item.tareWeightKg != null
          ? '${item.tareWeightKg!.toStringAsFixed(0)} kg'
          : '';
      final netStr = item.netWeightKg != null
          ? '${item.netWeightKg!.toStringAsFixed(0)} kg'
          : '';
      final statusFormatted = item.isCompleted ? 'Completed' : 'Pending';

      final line = [
        _escape(item.billNumber),
        _escape(dateTimeStr),
        _escape(item.vehicleNumber),
        _escape(item.partyName),
        _escape(item.materialName),
        _escape(grossStr),
        _escape(tareStr),
        _escape(netStr),
        item.amount.toStringAsFixed(0),
        _escape(statusFormatted),
      ].join(',');

      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Generates encoded bytes for the CSV content.
  Uint8List generateCsvBytes(List<WeighmentReportItem> records) {
    return Uint8List.fromList(utf8.encode(generateCsvString(records)));
  }

  String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
