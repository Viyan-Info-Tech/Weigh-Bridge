import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/repositories/report_repository.dart';
import 'package:weighbridge/features/report/domain/services/file_save_service.dart';
import 'package:weighbridge/features/report/domain/usecases/export_report_usecase.dart';
import 'package:weighbridge/features/report/presentation/bloc/report_bloc.dart';
import 'package:weighbridge/features/report/presentation/pages/report_page.dart';

class MockReportRepository extends Mock implements ReportRepository {}

class MockFileSaveService extends Mock implements FileSaveService {}

/// Hosts [ReportPage] inside an [IndexedStack] the same way the dashboard
/// shell does, so the page is kept alive across tab switches and only its
/// [ReportPage.isActive] flag flips.
class _IndexedStackHost extends StatefulWidget {
  const _IndexedStackHost();

  @override
  State<_IndexedStackHost> createState() => _IndexedStackHostState();
}

class _IndexedStackHostState extends State<_IndexedStackHost> {
  bool _reportTabActive = false;

  void showReportTab() => setState(() => _reportTabActive = true);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _reportTabActive ? 1 : 0,
      children: [
        const SizedBox.shrink(),
        ReportPage(isActive: _reportTabActive),
      ],
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ReportFilter());
  });

  final record = WeighmentReportItem(
    id: 1,
    billNumber: 'WB-2026-000001',
    createdAt: DateTime.now(),
    vehicleNumber: 'TN31CM20260789A',
    firstWeightKg: 25000,
    secondWeightKg: 6500,
  );

  /// Sets up a mock repository that counts every page fetch instead of using
  /// mocktail's verify, which consumes the matched calls on first read.
  MockReportRepository createRepo({required int Function() onFetch}) {
    final reportRepo = MockReportRepository();
    when(
      () => reportRepo.getReportRecords(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async {
      onFetch();
      return [record];
    });
    when(() => reportRepo.countReportRecords(any())).thenAnswer((_) async => 1);
    when(
      () => reportRepo.summarizeReportRecords(any()),
    ).thenAnswer((_) async => const ReportSummary(totalBills: 1));
    return reportRepo;
  }

  ReportBloc createBloc(MockReportRepository reportRepo) {
    final reportBloc = ReportBloc(
      reportRepository: reportRepo,
      exportReportUseCase: ExportReportUseCase(
        reportRepository: reportRepo,
        fileSaveService: MockFileSaveService(),
      ),
    );
    addTearDown(() async => reportBloc.close());
    return reportBloc;
  }

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  testWidgets(
    're-fetches the report automatically when the tab becomes active again',
    (tester) async {
      setDesktopSize(tester);
      var fetches = 0;
      final reportRepo = createRepo(onFetch: () => fetches++);
      final reportBloc = createBloc(reportRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ReportBloc>.value(
            value: reportBloc,
            child: const _IndexedStackHost(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The page is built once (like at app start) and loads once.
      expect(fetches, 1);

      // Simulate the user navigating away and back to the Reports tab.
      tester
          .state<_IndexedStackHostState>(find.byType(_IndexedStackHost))
          .showReportTab();
      await tester.pumpAndSettle();

      expect(
        fetches,
        2,
        reason: 'Switching back to the Reports tab must refresh the report.',
      );
      expect(find.text('WB-2026-000001'), findsOneWidget);
    },
  );

  testWidgets(
    'does not issue an extra query when the page rebuilds while already active',
    (tester) async {
      setDesktopSize(tester);
      var fetches = 0;
      final reportRepo = createRepo(onFetch: () => fetches++);
      final reportBloc = createBloc(reportRepo);

      Widget buildHost() => MaterialApp(
        home: BlocProvider<ReportBloc>.value(
          value: reportBloc,
          child: const ReportPage(isActive: true),
        ),
      );

      await tester.pumpWidget(buildHost());
      await tester.pumpAndSettle();
      expect(fetches, 1);

      // A rebuild that keeps the tab active must not query again.
      await tester.pumpWidget(buildHost());
      await tester.pumpAndSettle();

      expect(
        fetches,
        1,
        reason: 'Rebuilds of an already-active page must not re-query.',
      );
    },
  );
}
