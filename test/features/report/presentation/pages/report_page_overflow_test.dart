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

void main() {
  setUpAll(() {
    registerFallbackValue(const ReportFilter());
  });

  final allRecords = [
    WeighmentReportItem(
      id: 1,
      billNumber: 'WB-2026-000001',
      createdAt: DateTime(2026, 9, 18, 10, 30),
      vehicleNumber: 'TN31CM20260789A',
      material: 'Sand',
      description: 'CDM',
      containerNo: '12',
      firstWeightKg: 25000,
      secondWeightKg: 6500,
    ),
    WeighmentReportItem(
      id: 2,
      billNumber: 'WB-2026-000002',
      createdAt: DateTime(2026, 9, 18, 12, 45),
      vehicleNumber: 'KA01AB1234',
      material: null,
      description: null,
      containerNo: null,
      firstWeightKg: 0,
    ),
  ];

  ReportBloc createReportBloc(MockReportRepository reportRepo) {
    return ReportBloc(
      reportRepository: reportRepo,
      exportReportUseCase: ExportReportUseCase(
        reportRepository: reportRepo,
        fileSaveService: MockFileSaveService(),
      ),
    );
  }

  Future<ReportBloc> pumpReportPage(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final reportRepo = MockReportRepository();
    when(
      () => reportRepo.getReportRecords(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => allRecords);
    when(
      () => reportRepo.countReportRecords(any()),
    ).thenAnswer((_) async => allRecords.length);
    when(() => reportRepo.summarizeReportRecords(any())).thenAnswer((_) async {
      return ReportSummary(
        totalBills: allRecords.length,
        totalGrossWeightKg: 47000,
        totalTareWeightKg: 6500,
        totalNetWeightKg: 18500,
        completedCount: allRecords.where((i) => i.isCompleted).length,
      );
    });

    final reportBloc = createReportBloc(reportRepo);

    addTearDown(() async {
      await reportBloc.close();
    });

    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey(size),
        home: BlocProvider<ReportBloc>.value(
          value: reportBloc,
          child: const ReportPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    return reportBloc;
  }

  testWidgets(
    'renders the report table without RenderFlex overflow at any desktop size',
    (tester) async {
      final sizesToTest = const [
        Size(1920, 1080),
        Size(1600, 900),
        Size(1366, 768),
        Size(1280, 720),
        Size(1024, 768),
        Size(960, 720),
        Size(900, 700),
        Size(800, 600),
        Size(640, 480),
        Size(1280, 500),
      ];

      for (final size in sizesToTest) {
        final reportBloc = await pumpReportPage(tester, size: size);

        expect(
          tester.takeException(),
          isNull,
          reason: 'Exception at ${size.width}x${size.height}',
        );

        if (find.text('BILL NO').evaluate().isEmpty &&
            (size.width > 1000 || size.height > 600)) {
          // ignore: avoid_print
          print(
            'MISSING BILL NO @ ${size.width}x${size.height}: '
            'report=${reportBloc.state.status} '
            'records=${reportBloc.state.records.length} '
            'error=${reportBloc.state.errorMessage} '
            'hScrollCount=${tester.widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView)).length}',
          );
        }

        expect(
          find.text('BILL NO'),
          findsOneWidget,
          reason: 'Table header missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('MATERIAL'),
          findsOneWidget,
          reason: 'Material header missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('DESCRIPTION'),
          findsOneWidget,
          reason: 'Description header missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('CONTAINER NO.'),
          findsOneWidget,
          reason:
              'Container No. header missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('WB-2026-000001'),
          findsOneWidget,
          reason: 'bill number row missing at ${size.width}x${size.height}',
        );
        if (size.height >= 650) {
          expect(find.text('COMPLETED'), findsWidgets);
          expect(find.text('INCOMPLETE'), findsWidgets);
        }
      }
    },
  );

  testWidgets(
    'wraps the wide table in a horizontal scroll view at narrow widths',
    (tester) async {
      await pumpReportPage(tester, size: const Size(800, 600));

      final hScrollViews = tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .where((v) => v.scrollDirection == Axis.horizontal);
      expect(hScrollViews, isNotEmpty);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(-600, 0),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      final visibleScroll = tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .firstWhere((v) => v.scrollDirection == Axis.horizontal);
      expect(visibleScroll.controller, isNotNull);
    },
  );

  testWidgets(
    'resizes live from wide to narrow and back without layout exceptions',
    (tester) async {
      await pumpReportPage(tester, size: const Size(1600, 900));

      final resizeSteps = const [
        Size(1366, 768),
        Size(1152, 720),
        Size(960, 720),
        Size(900, 700),
        Size(800, 600),
        Size(700, 550),
        Size(900, 600),
        Size(1280, 720),
        Size(1920, 1080),
      ];

      for (final step in resizeSteps) {
        tester.view.physicalSize = step;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Exception while resizing to ${step.width}x${step.height}',
        );
      }
    },
  );

  testWidgets('status badges ellipsize instead of overflowing the badge', (
    tester,
  ) async {
    await pumpReportPage(tester, size: const Size(800, 600));

    final statusTexts = tester.widgetList<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data == 'COMPLETED' || w.data == 'PENDING'),
      ),
    );
    for (final text in statusTexts) {
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    }
  });
}
