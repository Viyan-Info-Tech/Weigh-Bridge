import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/core/hardware/scale/data/fake_scale_service.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_service.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/printing/print_service.dart';
import 'package:weighbridge/core/status/app_status_cubit.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockPrintService extends Mock implements PrintService {}

class MockLicenseService extends Mock implements LicenseService {}

/// Wraps [child] with the providers HomePage's status bar requires:
/// a [ScaleService] plus an [AppStatusCubit] wired to database, printer
/// and license probes.
///
/// Auto-created mocks are stubbed optimistically (open / available / valid).
/// Mocks passed in by the caller keep the caller's own stubs, so tests can
/// supply failing probes.
Widget wrapWithStatusProviders(
  Widget child, {
  ScaleService? scaleService,
  MockAppDatabase? database,
  MockPrintService? printService,
  MockLicenseService? licenseService,
}) {
  final scale = scaleService ?? FakeScaleService();
  final db = database ?? MockAppDatabase();
  final printer = printService ?? MockPrintService();
  final license = licenseService ?? MockLicenseService();

  if (database == null) {
    when(() => db.healthCheck()).thenAnswer((_) async => true);
  }
  if (printService == null) {
    when(() => printer.isPrinterAvailable()).thenAnswer((_) async => true);
  }
  if (licenseService == null) {
    when(() => license.validate()).thenAnswer((_) async => LicenseStatus.valid);
    when(() => license.loadLicense()).thenAnswer((_) async => null);
  }

  return MultiRepositoryProvider(
    providers: [RepositoryProvider<ScaleService>.value(value: scale)],
    child: BlocProvider<AppStatusCubit>(
      create: (_) => AppStatusCubit(
        scaleService: scale,
        database: db,
        printService: printer,
        licenseService: license,
        pollInterval: const Duration(days: 365),
      ),
      child: child,
    ),
  );
}
