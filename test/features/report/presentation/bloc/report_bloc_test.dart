import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/repositories/report_repository.dart';
import 'package:weighbridge/features/report/domain/services/file_save_service.dart';
import 'package:weighbridge/features/report/domain/usecases/export_report_usecase.dart';
import 'package:weighbridge/features/report/presentation/bloc/report_bloc.dart';
import 'package:weighbridge/features/report/presentation/bloc/report_event.dart';
import 'package:weighbridge/features/report/presentation/bloc/report_state.dart';

class MockReportRepository extends Mock implements ReportRepository {}

class MockFileSaveService extends Mock implements FileSaveService {}

void main() {
  late MockReportRepository reportRepo;
  late ReportBloc bloc;

  /// The page size the bloc actually requests. Tests build totals above this so
  /// paging genuinely happens rather than one page covering everything.
  const pageSize = ReportFilter.defaultPageSize;

  final created = DateTime(2026, 9, 18, 10, 30);

  WeighmentReportItem item(int id) => WeighmentReportItem(
    id: id,
    billNumber: 'WB-${id.toString().padLeft(5, '0')}',
    createdAt: created,
    vehicleNumber: 'TN31TEST$id',
    firstWeightKg: 20000,
    firstWeightType: 'GROSS',
    secondWeightKg: 5000,
  );

  /// Serves [total] items one page at a time.
  ///
  /// [total] must exceed [pageSize] so the bloc genuinely has to page instead of
  /// receiving the whole result in its first query.
  void stubPaged(int total) {
    when(
      () => reportRepo.getReportRecords(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((invocation) async {
      final limit = invocation.namedArguments[#limit] as int?;
      final offset = invocation.namedArguments[#offset] as int? ?? 0;
      if (limit == null) {
        return List.generate(total, (i) => item(i + 1));
      }
      final end = (offset + limit).clamp(0, total);
      return List.generate(end - offset, (i) => item(offset + i + 1));
    });
    when(
      () => reportRepo.countReportRecords(any()),
    ).thenAnswer((_) async => total);
    when(() => reportRepo.summarizeReportRecords(any())).thenAnswer(
      (_) async => ReportSummary(
        totalBills: total,
        totalGrossWeightKg: 20000.0 * total,
        totalTareWeightKg: 5000.0 * total,
        totalNetWeightKg: 15000.0 * total,
        completedCount: total,
      ),
    );
  }

  ReportBloc buildBloc() {
    return ReportBloc(
      reportRepository: reportRepo,
      exportReportUseCase: ExportReportUseCase(
        reportRepository: reportRepo,
        fileSaveService: MockFileSaveService(),
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(const ReportFilter());
  });

  setUp(() {
    reportRepo = MockReportRepository();
  });

  tearDown(() async {
    await bloc.close();
  });

  group('ReportBloc initial load', () {
    test('loads only the first page but reports the full total', () async {
      final total = pageSize + 50;
      stubPaged(total);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      final state = bloc.state;
      expect(state.records, hasLength(pageSize));
      expect(
        state.totalRecords,
        total,
        reason: 'the footer total must not be the loaded page length',
      );
      expect(state.hasMoreRecords, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.pageSize, pageSize);
    });

    test('summary describes every match, not just the loaded page', () async {
      final total = pageSize + 50;
      stubPaged(total);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      expect(bloc.state.summary.totalBills, total);
      expect(bloc.state.summary.totalNetWeightKg, 15000.0 * total);
      expect(bloc.state.records, hasLength(pageSize));
    });

    test('reports no more pages when everything fits in one page', () async {
      stubPaged(2);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      expect(bloc.state.records, hasLength(2));
      expect(bloc.state.hasMoreRecords, isFalse);
    });
  });

  group('ReportBloc LoadNextReportPage', () {
    test(
      'appends the next page using the loaded length as the offset',
      () async {
        final total = pageSize + 50;
        stubPaged(total);
        bloc = buildBloc();

        bloc.add(const LoadReportInitial());
        await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

        bloc.add(const LoadNextReportPage());
        await bloc.stream.firstWhere(
          (s) => !s.isLoadingMore && s.records.length > pageSize,
        );

        expect(bloc.state.records, hasLength(total));
        expect(
          bloc.state.records.map((r) => r.id),
          List.generate(total, (i) => i + 1),
          reason: 'the new page must follow on, not replace what is loaded',
        );
        expect(bloc.state.isLoadingMore, isFalse);

        verify(
          () => reportRepo.getReportRecords(
            any(),
            limit: pageSize,
            offset: pageSize,
          ),
        ).called(1);
      },
    );

    test('keeps totals untouched while appending pages', () async {
      final total = pageSize + 50;
      stubPaged(total);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);
      final firstTotal = bloc.state.totalRecords;
      final firstSummary = bloc.state.summary;

      bloc.add(const LoadNextReportPage());
      await bloc.stream.firstWhere((s) => s.records.length > pageSize);

      expect(bloc.state.totalRecords, firstTotal);
      expect(bloc.state.summary, firstSummary);
      // The totals were fetched exactly once, by the initial load; appending a
      // page must not re-query them.
      verify(() => reportRepo.countReportRecords(any())).called(1);
      verify(() => reportRepo.summarizeReportRecords(any())).called(1);
    });

    test('does nothing once every page is loaded', () async {
      stubPaged(2);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      bloc.add(const LoadNextReportPage());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.records, hasLength(2));
      verify(
        () => reportRepo.getReportRecords(
          any(),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
    });

    test('ignores a second request while a page is still loading', () async {
      final total = pageSize * 2 + 10;
      final completer = Completer<List<WeighmentReportItem>>();
      when(
        () => reportRepo.getReportRecords(
          any(),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((invocation) async {
        final offset = invocation.namedArguments[#offset] as int? ?? 0;
        if (offset > 0) return completer.future;
        return List.generate(pageSize, (i) => item(i + 1));
      });
      when(
        () => reportRepo.countReportRecords(any()),
      ).thenAnswer((_) async => total);
      when(
        () => reportRepo.summarizeReportRecords(any()),
      ).thenAnswer((_) async => const ReportSummary(totalBills: 9));

      bloc = buildBloc();
      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      bloc.add(const LoadNextReportPage());
      await bloc.stream.firstWhere((s) => s.isLoadingMore);

      // A second request while the first is in flight must not stack another
      // query, which would otherwise duplicate rows on append.
      bloc.add(const LoadNextReportPage());
      await Future<void>.delayed(Duration.zero);

      verify(
        () => reportRepo.getReportRecords(
          any(),
          limit: pageSize,
          offset: pageSize,
        ),
      ).called(1);

      completer.complete(
        List.generate(pageSize, (i) => item(pageSize + i + 1)),
      );
      await bloc.stream.firstWhere((s) => s.records.length == pageSize * 2);
      expect(bloc.state.isLoadingMore, isFalse);
    });

    test('surfaces a page failure without corrupting what is loaded', () async {
      stubPaged(pageSize + 50);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      when(
        () => reportRepo.getReportRecords(
          any(),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(Exception('boom'));

      bloc.add(const LoadNextReportPage());
      await bloc.stream.firstWhere((s) => s.errorMessage != null);

      expect(bloc.state.records, hasLength(pageSize));
      expect(bloc.state.isLoadingMore, isFalse);
      expect(bloc.state.errorMessage, contains('boom'));
    });
  });

  group('ReportBloc filter changes', () {
    test('a filter change resets paging to the first page', () async {
      final total = pageSize + 50;
      stubPaged(total);
      bloc = buildBloc();

      bloc.add(const LoadReportInitial());
      await bloc.stream.firstWhere((s) => s.status == ReportStatus.loaded);

      bloc.add(const LoadNextReportPage());
      await bloc.stream.firstWhere((s) => s.records.length > pageSize);
      expect(bloc.state.records, hasLength(total));

      bloc.add(const ReportVehicleFilterChanged('MH12'));
      await bloc.stream.firstWhere((s) => s.filter.vehicleNumber == 'MH12');
      // Vehicle filter only updates the draft filter; applying it re-queries.
      expect(bloc.state.records, hasLength(total));

      bloc.add(const ApplyReportFilters());
      await bloc.stream.firstWhere((s) => s.records.length == pageSize);

      expect(
        bloc.state.records,
        hasLength(pageSize),
        reason:
            'a filter change replaces the result set and restarts at page 1',
      );
      expect(bloc.state.totalRecords, total);
      verify(
        () => reportRepo.getReportRecords(any(), limit: pageSize, offset: 0),
      ).called(2);
    });
  });
}
