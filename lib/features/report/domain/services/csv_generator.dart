import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../entities/report_filter.dart';
import '../entities/weighment_report_item.dart';

class CsvGenerator {
  const CsvGenerator();

  /// Production-grade filename generator based on report filters:
  /// e.g. weighment_report_2026-09-13.csv
  /// e.g. weighment_report_2026-09-01_to_2026-09-13.csv
  String generateSuggestedFileName(ReportFilter filter) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final startDate = filter.effectiveStartDate;
    final endDate = filter.effectiveEndDate;

    final isSameDay =
        startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    String datePart;
    if (isSameDay) {
      datePart = dateFormat.format(startDate);
    } else {
      datePart =
          '${dateFormat.format(startDate)}_to_${dateFormat.format(endDate)}';
    }

    return 'weighment_report_$datePart.csv';
  }

  /// Generates clean tabular CSV data with UTF-8 BOM for Excel compatibility.
  String generateCsvString(
    List<WeighmentReportItem> records, {
    String? weightUnit,
  }) {
    final buffer = StringBuffer();
    // Prepend UTF-8 Byte Order Mark (BOM) for Excel
    buffer.write('\uFEFF');

    // Clean, standard CSV Header
    buffer.writeln(
      'Bill No,Date & Time,Vehicle,Customer,Material,Gross Weight,Tare Weight,Net Weight,Weight Unit,Status',
    );

    final dateTimeFormat = DateFormat('dd/MM/yyyy hh:mm a');

    for (final item in records) {
      final dateTimeStr = dateTimeFormat.format(item.createdAt);
      final unit = weightUnit ?? item.weightUnit;
      final isTon =
          unit.toLowerCase() == 'ton' || unit.toLowerCase() == 'tonne';
      final decimals = isTon ? 3 : 0;
      double? toDisplay(double? kg) =>
          kg == null ? null : (isTon ? kg / 1000 : kg);

      // Represent empty weight values as empty strings in CSV so cells are clean
      final grossStr = item.grossWeightKg != null
          ? '${toDisplay(item.grossWeightKg)!.toStringAsFixed(decimals)} $unit'
          : '';
      final tareStr = item.tareWeightKg != null
          ? '${toDisplay(item.tareWeightKg)!.toStringAsFixed(decimals)} $unit'
          : '';
      final netStr = item.netWeightKg != null
          ? '${toDisplay(item.netWeightKg)!.toStringAsFixed(decimals)} $unit'
          : '';
      // Completion follows the weighbridge rule: a bill with at least one
      // captured weight (gross or tare) is Completed; no weight is Incomplete.
      final statusFormatted = item.isCompleted ? 'Completed' : 'Incomplete';

      final line = [
        _escape(item.billNumber),
        _escape(dateTimeStr),
        _escape(item.vehicleNumber),
        _escape(item.customerName),
        _escape(item.materialName),
        _escape(grossStr),
        _escape(tareStr),
        _escape(netStr),
        _escape(unit),
        _escape(statusFormatted),
      ].join(',');

      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Generates encoded bytes for the CSV content.
  Uint8List generateCsvBytes(
    List<WeighmentReportItem> records, {
    String? weightUnit,
  }) {
    return Uint8List.fromList(
      utf8.encode(generateCsvString(records, weightUnit: weightUnit)),
    );
  }

  String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
