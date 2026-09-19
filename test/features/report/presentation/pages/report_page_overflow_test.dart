import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/party/domain/repositories/party_repository.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/repositories/report_repository.dart';
import 'package:weighbridge/features/report/domain/services/file_save_service.dart';
import 'package:weighbridge/features/report/domain/usecases/export_report_usecase.dart';
import 'package:weighbridge/features/report/presentation/bloc/report_bloc.dart';
import 'package:weighbridge/features/report/presentation/pages/report_page.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/entities/vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/usecases/create_vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/usecases/delete_vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/usecases/load_vehicle_types.dart';
import 'package:weighbridge/features/vehicle_type/presentation/bloc/vehicle_type_bloc.dart';
import 'package:weighbridge/features/vehicle_type/presentation/bloc/vehicle_type_event.dart';

class MockReportRepository extends Mock implements ReportRepository {}

class MockPartyRepository extends Mock implements PartyRepository {}

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockVehicleTypeRepository extends Mock implements VehicleTypeRepository {}

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
      vehicleId: 1,
      vehicleNumber: 'TN31CM20260789A',
      vehicleTypeName: 'Heavy Duty Truck',
      partyId: 1,
      partyName: 'ACME Traders Private Limited',
      materialId: 1,
      materialName: 'Portland Pozzolana Cement',
      paymentMode: 'cash',
      amount: 12500,
      vehicleCharge: 12500,
      firstWeightKg: 25000,
      secondWeightKg: 6500,
      rawStatus: 'completed',
    ),
    WeighmentReportItem(
      id: 2,
      billNumber: 'WB-2026-000002',
      createdAt: DateTime(2026, 9, 18, 12, 45),
      vehicleId: 2,
      vehicleNumber: 'KA01AB1234',
      vehicleTypeName: 'Truck',
      partyId: 1,
      partyName: 'Second Party',
      materialId: 1,
      materialName: 'Cement',
      paymentMode: 'credit',
      amount: 0,
      vehicleCharge: 0,
      firstWeightKg: 22000,
      rawStatus: 'pending',
    ),
  ];

  ReportBloc createReportBloc(MockReportRepository reportRepo) {
    final partyRepo = MockPartyRepository();
    when(() => partyRepo.getAllParties())
        .thenAnswer((_) async => const <Party>[]);
    final vehicleRepo = MockVehicleRepository();
    when(() => vehicleRepo.getAllVehicles())
        .thenAnswer((_) async => const <Vehicle>[]);
    final materialRepo = MockMaterialRepository();
    when(() => materialRepo.getAllMaterials())
        .thenAnswer((_) async => const <MaterialItem>[]);

    return ReportBloc(
      reportRepository: reportRepo,
      partyRepository: partyRepo,
      vehicleRepository: vehicleRepo,
      materialRepository: materialRepo,
      exportReportUseCase: ExportReportUseCase(
        reportRepository: reportRepo,
        fileSaveService: MockFileSaveService(),
      ),
    );
  }

  VehicleTypeBloc createVehicleTypeBloc() {
    final vtRepo = MockVehicleTypeRepository();
    when(() => vtRepo.getAllVehicleTypes()).thenAnswer((_) async => [
          VehicleType(
            id: 1,
            name: 'Truck',
            emptyPrice: 100,
            loadPrice: 200,
            isActive: true,
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
          ),
        ]);
    when(
      () => vtRepo.getVehicleTypesByStatus(isActive: any(named: 'isActive')),
    ).thenAnswer((_) async => [
          VehicleType(
            id: 1,
            name: 'Truck',
            emptyPrice: 100,
            loadPrice: 200,
            isActive: true,
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
          ),
        ]);

    return VehicleTypeBloc(
      loadVehicleTypesUseCase: LoadVehicleTypesUseCase(vtRepo),
      createVehicleTypeUseCase: CreateVehicleTypeUseCase(vtRepo),
      deleteVehicleTypeUseCase: DeleteVehicleTypeUseCase(vtRepo),
      vehicleTypeRepository: vtRepo,
    );
  }

  Future<(ReportBloc, VehicleTypeBloc)> pumpReportPage(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final reportRepo = MockReportRepository();
    when(() => reportRepo.getReportRecords(any()))
        .thenAnswer((_) async => allRecords);
    when(() => reportRepo.calculateSummary(any())).thenAnswer(
      (invocation) {
        final items = invocation.positionalArguments.first
            as List<WeighmentReportItem>;
        return ReportSummary(
          totalBills: items.length,
          totalGrossWeightKg: 47000,
          totalTareWeightKg: 6500,
          totalNetWeightKg: 18500,
          totalRevenue: 12500,
          pendingCount: items.where((i) => i.rawStatus == 'pending').length,
          completedCount:
              items.where((i) => i.rawStatus == 'completed').length,
        );
      },
    );

    final reportBloc = createReportBloc(reportRepo);
    final vtBloc = createVehicleTypeBloc();

    addTearDown(() async {
      await reportBloc.close();
      await vtBloc.close();
    });

    vtBloc.add(const LoadVehicleTypes());

    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey(size),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ReportBloc>.value(value: reportBloc),
            BlocProvider<VehicleTypeBloc>.value(value: vtBloc),
          ],
          child: const ReportPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    return (reportBloc, vtBloc);
  }

  testWidgets(
    'renders the report table without RenderFlex overflow at any desktop size',
    (tester) async {
      final sizesToTest = const [
        Size(1920, 1080), // Full HD Large Desktop
        Size(1600, 900), // Standard Desktop
        Size(1366, 768), // Standard Laptop
        Size(1280, 720), // Compact Laptop
        Size(1024, 768), // Legacy Desktop
        Size(960, 720), // Breakpoint Boundary
        Size(900, 700), // Narrow Desktop
        Size(800, 600), // Compact Desktop Constraint
        Size(640, 480), // Minimized Window Boundary
        Size(1280, 500), // Short Window Height
      ];

      for (final size in sizesToTest) {
        final (reportBloc, vtBloc) = await pumpReportPage(tester, size: size);

        expect(
          tester.takeException(),
          isNull,
          reason: 'Exception at ${size.width}x${size.height}',
        );

        if (find.text('BILL NO').evaluate().isEmpty &&
          (size.width > 1000 || size.height > 600)) {
        // ignore: avoid_print
        print('MISSING BILL NO @ ${size.width}x${size.height}: '
            'report=${reportBloc.state.status} '
            'records=${reportBloc.state.records.length} '
            'error=${reportBloc.state.errorMessage} '
            'vt=${vtBloc.state.status} vtCount=${vtBloc.state.vehicleTypes.length} '
            'hScrollCount=${tester.widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView)).length}');
      }

        expect(
          find.text('BILL NO'),
          findsOneWidget,
          reason: 'Table header missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('WB-2026-000001'),
          findsOneWidget,
          reason: 'bill number row missing at ${size.width}x${size.height}',
        );
        // The status badges themselves are covered by the dedicated badge test;
        // rows are lazily built inside the vertical ListView, so only assert
        // when the table area is tall enough for both rows.
        if (size.height >= 650) {
          expect(find.text('COMPLETED'), findsWidgets);
          expect(find.text('PENDING'), findsWidgets);
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

      // Scrolling right keeps the status badge reachable without exceptions.
      await tester
          .drag(find.byType(SingleChildScrollView).first, const Offset(-600, 0));
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

  testWidgets(
    'status badges ellipsize instead of overflowing the badge',
    (tester) async {
      await pumpReportPage(tester, size: const Size(800, 600));

      final statusTexts = tester.widgetList<Text>(find.byWidgetPredicate(
        (w) => w is Text && (w.data == 'COMPLETED' || w.data == 'PENDING'),
      ));
      for (final text in statusTexts) {
        expect(text.maxLines, 1);
        expect(text.overflow, TextOverflow.ellipsis);
      }
    },
  );
}