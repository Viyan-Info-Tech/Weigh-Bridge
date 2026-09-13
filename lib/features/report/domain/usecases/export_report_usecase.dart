import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../entities/report_filter.dart';
import '../repositories/report_repository.dart';
import '../services/csv_generator.dart';
import '../services/file_save_service.dart';

enum ExportResultType {
  success,
  noRecords,
  cancelled,
  failure,
}

class ExportReportResult {
  final ExportResultType type;
  final String? filePath;
  final String? fileName;
  final String? errorMessage;

  const ExportReportResult({
    required this.type,
    this.filePath,
    this.fileName,
    this.errorMessage,
  });

  factory ExportReportResult.success(String filePath, String fileName) =>
      ExportReportResult(
        type: ExportResultType.success,
        filePath: filePath,
        fileName: fileName,
      );

  factory ExportReportResult.noRecords() =>
      const ExportReportResult(type: ExportResultType.noRecords);

  factory ExportReportResult.cancelled() =>
      const ExportReportResult(type: ExportResultType.cancelled);

  factory ExportReportResult.failure(String message) =>
      ExportReportResult(type: ExportResultType.failure, errorMessage: message);
}

class ExportReportUseCase {
  final ReportRepository _reportRepository;
  final FileSaveService _fileSaveService;
  final CsvGenerator _csvGenerator;

  ExportReportUseCase({
    required ReportRepository reportRepository,
    required FileSaveService fileSaveService,
    CsvGenerator? csvGenerator,
  })  : _reportRepository = reportRepository,
        _fileSaveService = fileSaveService,
        _csvGenerator = csvGenerator ?? const CsvGenerator();

  Future<ExportReportResult> call(ReportFilter filter) async {
    try {
      // 1. Fetch matching records according to current report filters
      final records = await _reportRepository.getReportRecords(filter);

      // 2. If there are no records, notify with a clean domain result
      if (records.isEmpty) {
        return ExportReportResult.noRecords();
      }

      // 3. Generate Excel-compatible UTF-8 BOM CSV content and suggested filename
      final bytes = _csvGenerator.generateCsvBytes(records);
      final suggestedFileName = _csvGenerator.generateSuggestedFileName(filter);

      // 4. Open native Save File dialog
      final filePath = await _fileSaveService.saveFile(
        suggestedFileName: suggestedFileName,
        bytes: bytes,
        mimeType: 'text/csv',
      );

      // 5. If user cancelled the dialog, return cancelled silently
      if (filePath == null) {
        return ExportReportResult.cancelled();
      }

      final fileName = p.basename(filePath);
      return ExportReportResult.success(filePath, fileName);
    } catch (e, stackTrace) {
      // Log technical exception for developer debugging
      debugPrint('ExportReportUseCase technical error: $e\n$stackTrace');
      return ExportReportResult.failure(
        'The file could not be saved to the selected location.\n\nPlease choose another location and try again.',
      );
    }
  }
}
