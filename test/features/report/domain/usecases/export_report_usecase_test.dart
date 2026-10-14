import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/repositories/report_repository.dart';
import 'package:weighbridge/features/report/domain/services/csv_generator.dart';
import 'package:weighbridge/features/report/domain/services/file_save_service.dart';
import 'package:weighbridge/features/report/domain/usecases/export_report_usecase.dart';

class MockReportRepository extends Mock implements ReportRepository {}

class MockFileSaveService extends Mock implements FileSaveService {}

void main() {
  late MockReportRepository mockRepo;
  late MockFileSaveService mockSaveService;
  late ExportReportUseCase useCase;

  final record = WeighmentReportItem(
    id: 1,
    billNumber: 'WB-00001',
    createdAt: DateTime(2026, 9, 18, 10, 30),
    vehicleNumber: 'TN31CM2026',
    firstWeightKg: 20000,
    secondWeightKg: 5000,
  );

  setUpAll(() {
    registerFallbackValue(const ReportFilter());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepo = MockReportRepository();
    mockSaveService = MockFileSaveService();
    useCase = ExportReportUseCase(
      reportRepository: mockRepo,
      fileSaveService: mockSaveService,
    );
  });

  test('returns noRecords when the filter matches nothing', () async {
    when(() => mockRepo.getReportRecords(any())).thenAnswer((_) async => []);

    final result = await useCase.call(const ReportFilter());

    expect(result.type, ExportResultType.noRecords);
    verify(() => mockRepo.getReportRecords(any())).called(1);
    verifyNever(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: any(named: 'mimeType'),
      ),
    );
  });

  test('returns success with the saved path and basename', () async {
    when(
      () => mockRepo.getReportRecords(any()),
    ).thenAnswer((_) async => [record]);
    when(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).thenAnswer((_) async => 'C:\\Reports\\weighment_report.csv');

    final result = await useCase.call(const ReportFilter());

    expect(result.type, ExportResultType.success);
    expect(result.filePath, 'C:\\Reports\\weighment_report.csv');
    expect(result.fileName, 'weighment_report.csv');
    verify(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).called(1);
  });

  test('passes a suggested CSV filename based on the filter', () async {
    when(
      () => mockRepo.getReportRecords(any()),
    ).thenAnswer((_) async => [record]);
    when(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).thenAnswer((_) async => null);

    final result = await useCase.call(const ReportFilter());

    expect(result.type, ExportResultType.cancelled);
    final captured = verify(
      () => mockSaveService.saveFile(
        suggestedFileName: captureAny(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).captured;
    expect(captured.single as String, endsWith('.csv'));
  });

  test('returns cancelled when the user dismisses the dialog', () async {
    when(
      () => mockRepo.getReportRecords(any()),
    ).thenAnswer((_) async => [record]);
    when(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).thenAnswer((_) async => null);

    final result = await useCase.call(const ReportFilter());

    expect(result.type, ExportResultType.cancelled);
  });

  test('writes UTF-8 BOM bytes produced by the CSV generator', () async {
    when(
      () => mockRepo.getReportRecords(any()),
    ).thenAnswer((_) async => [record]);
    Uint8List? capturedBytes;
    when(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).thenAnswer((invocation) async {
      capturedBytes = invocation.namedArguments[#bytes] as Uint8List;
      return 'C:\\out.csv';
    });

    final result = await useCase.call(const ReportFilter());

    expect(result.type, ExportResultType.success);
    final csv = const CsvGenerator().generateCsvString([record]);
    expect(csv.startsWith('\uFEFF'), isTrue);
    expect(capturedBytes, orderedEquals(utf8.encode(csv)));
  });

  test('returns failure when saving throws', () async {
    when(
      () => mockRepo.getReportRecords(any()),
    ).thenAnswer((_) async => [record]);
    when(
      () => mockSaveService.saveFile(
        suggestedFileName: any(named: 'suggestedFileName'),
        bytes: any(named: 'bytes'),
        mimeType: 'text/csv',
      ),
    ).thenThrow(Exception('disk full'));

    final result = await useCase.call(const ReportFilter());

    expect(result.type, ExportResultType.failure);
    expect(result.errorMessage, contains('could not be saved'));
  });
}
