// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/services/report_pdf_generator.dart';

String _extractPdfText(Uint8List bytes) {
  final raw = latin1.decode(bytes);
  final buffer = StringBuffer();
  final streamPattern = RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true);
  for (final match in streamPattern.allMatches(raw)) {
    final streamContent = match.group(1)!;
    final streamBytes = Uint8List.fromList(streamContent.codeUnits);
    try {
      final decompressed = ZLibDecoder().convert(streamBytes);
      buffer.write(utf8.decode(decompressed));
    } catch (_) {}
  }
  return buffer.toString();
}

int _countPdfPages(Uint8List bytes) {
  final raw = latin1.decode(bytes);
  final match = RegExp(r'/Count\s+(\d+)').firstMatch(raw);
  if (match != null) return int.parse(match.group(1)!);
  return -1;
}

void main() {
  test('extract PDF text', () async {
    final generator = ReportPdfGenerator();
    final record = WeighmentReportItem(
      id: 1,
      billNumber: 'WB-00001',
      createdAt: DateTime(2026, 9, 18, 10, 30),
      vehicleNumber: 'TN31CM2026',
      firstWeightKg: 20000,
      secondWeightKg: 5000,
      weightUnit: 'ton',
    );
    final summary = const ReportSummary(
      totalBills: 1,
      totalGrossWeightKg: 20000,
      totalTareWeightKg: 5000,
      totalNetWeightKg: 15000,
      completedCount: 1,
    );

    final bytes = await generator.generateReportPdf(
      records: [record],
      summary: summary,
      filter: const ReportFilter(),
      companyName: 'Test Company',
    );

    print('PDF length: ${bytes.length}');
    print('Page count: ${_countPdfPages(bytes)}');

    final text = _extractPdfText(bytes);
    print('Extracted text length: ${text.length}');
    print('Contains WB-00001: ${text.contains('WB-00001')}');
    print('Contains Test Company: ${text.contains('Test Company')}');
    print('Contains TN31CM2026: ${text.contains('TN31CM2026')}');
    print('Contains WEIGHMENT REPORT: ${text.contains('WEIGHMENT REPORT')}');
    print('Contains CONFIDENTIAL: ${text.contains('CONFIDENTIAL')}');

    if (text.length > 200) {
      print('First 500 chars: ${text.substring(0, 500)}');
    } else {
      print('Full text: $text');
    }
  });
}
