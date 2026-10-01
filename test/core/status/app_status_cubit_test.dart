import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_service.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_status.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/license_service.dart';
import 'package:weighbridge/core/printing/print_service.dart';
import 'package:weighbridge/core/status/app_status_cubit.dart';
import 'package:weighbridge/core/status/app_status_state.dart';

class MockScaleService extends Mock implements ScaleService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockPrintService extends Mock implements PrintService {}

class MockLicenseService extends Mock implements LicenseService {}

License licenseExpiringIn(int days) {
  return License(
    licenseId: 'LIC-1',
    productId: 'weighbridge',
    customerId: 'C-1',
    customerName: 'ACME',
    machineHash: 'hash',
    issuedAt: DateTime.now(),
    expiresAt: DateTime.now().add(Duration(days: days, hours: 1)),
    licenseType: 'subscription',
    licenseVersion: 1,
    signature: 'sig',
  );
}

void main() {
  late MockScaleService scaleService;
  late MockAppDatabase database;
  late MockPrintService printService;
  late MockLicenseService licenseService;
  late StreamController<ScaleStatus> scaleController;
  AppStatusCubit? cubit;

  void stubHappyPath({
    bool dbHealthy = true,
    bool printerAvailable = true,
    LicenseStatus licenseStatus = LicenseStatus.valid,
    License? license,
  }) {
    when(() => database.healthCheck()).thenAnswer((_) async => dbHealthy);
    when(
      () => printService.isPrinterAvailable(),
    ).thenAnswer((_) async => printerAvailable);
    when(
      () => licenseService.validate(),
    ).thenAnswer((_) async => licenseStatus);
    when(() => licenseService.loadLicense()).thenAnswer((_) async => license);
  }

  AppStatusCubit buildCubit() {
    final built = AppStatusCubit(
      scaleService: scaleService,
      database: database,
      printService: printService,
      licenseService: licenseService,
      pollInterval: const Duration(days: 365),
    );
    cubit = built;
    return built;
  }

  setUp(() {
    scaleService = MockScaleService();
    database = MockAppDatabase();
    printService = MockPrintService();
    licenseService = MockLicenseService();
    scaleController = StreamController<ScaleStatus>.broadcast();
    when(() => scaleService.currentStatus).thenReturn(const ScaleStatus());
    when(
      () => scaleService.statusStream,
    ).thenAnswer((_) => scaleController.stream);
    stubHappyPath();
  });

  tearDown(() async {
    await cubit?.close();
    cubit = null;
    await scaleController.close();
  });

  group('scale tracking', () {
    test('seeds state from scaleService.currentStatus', () {
      when(
        () => scaleService.currentStatus,
      ).thenReturn(const ScaleStatus(state: ScaleConnectionState.connected));

      final built = buildCubit();
      expect(built.state.scale, ScaleStatusDisplay.connected);
    });

    test('follows statusStream transitions', () async {
      final built = buildCubit();
      expect(built.state.scale, ScaleStatusDisplay.disconnected);

      scaleController.add(
        const ScaleStatus(state: ScaleConnectionState.connecting),
      );
      await Future<void>.delayed(Duration.zero);
      expect(built.state.scale, ScaleStatusDisplay.connecting);

      scaleController.add(
        const ScaleStatus(state: ScaleConnectionState.connected),
      );
      await Future<void>.delayed(Duration.zero);
      expect(built.state.scale, ScaleStatusDisplay.connected);

      scaleController.add(
        const ScaleStatus(state: ScaleConnectionState.connected, stale: true),
      );
      await Future<void>.delayed(Duration.zero);
      expect(built.state.scale, ScaleStatusDisplay.stale);

      scaleController.add(const ScaleStatus(state: ScaleConnectionState.error));
      await Future<void>.delayed(Duration.zero);
      expect(built.state.scale, ScaleStatusDisplay.disconnected);
    });

    test('reconnecting maps to connecting', () async {
      final built = buildCubit();

      scaleController.add(
        const ScaleStatus(state: ScaleConnectionState.reconnecting),
      );
      await Future<void>.delayed(Duration.zero);
      expect(built.state.scale, ScaleStatusDisplay.connecting);
    });
  });

  group('database probe', () {
    test('healthy database reports open', () async {
      final built = buildCubit();
      await built.refresh();
      expect(built.state.database, DatabaseStatusDisplay.open);
    });

    test('unhealthy database reports error', () async {
      stubHappyPath(dbHealthy: false);
      final built = buildCubit();
      await built.refresh();
      expect(built.state.database, DatabaseStatusDisplay.error);
    });

    test('probe exception reports error', () async {
      when(() => database.healthCheck()).thenThrow(Exception('db gone'));
      final built = buildCubit();
      await built.refresh();
      expect(built.state.database, DatabaseStatusDisplay.error);
    });
  });

  group('printer probe', () {
    test('printer found reports available', () async {
      final built = buildCubit();
      await built.refresh();
      expect(built.state.printer, PrinterStatusDisplay.available);
    });

    test('no printer reports offline', () async {
      stubHappyPath(printerAvailable: false);
      final built = buildCubit();
      await built.refresh();
      expect(built.state.printer, PrinterStatusDisplay.offline);
    });

    test('probe exception reports offline', () async {
      when(
        () => printService.isPrinterAvailable(),
      ).thenThrow(Exception('spooler down'));
      final built = buildCubit();
      await built.refresh();
      expect(built.state.printer, PrinterStatusDisplay.offline);
    });
  });

  group('license probe', () {
    test('valid license reports valid', () async {
      final built = buildCubit();
      await built.refresh();
      expect(built.state.license, LicenseStatusDisplay.valid);
      expect(built.state.licenseDaysRemaining, isNull);
    });

    test(
      'license expiring within the threshold reports expiring with days',
      () async {
        stubHappyPath(license: licenseExpiringIn(3));
        final built = buildCubit();
        await built.refresh();
        expect(built.state.license, LicenseStatusDisplay.expiring);
        expect(built.state.licenseDaysRemaining, 3);
      },
    );

    test('license with plenty of time left reports valid', () async {
      stubHappyPath(license: licenseExpiringIn(90));
      final built = buildCubit();
      await built.refresh();
      expect(built.state.license, LicenseStatusDisplay.valid);
      expect(built.state.licenseDaysRemaining, isNull);
    });

    test('expired license reports invalid', () async {
      stubHappyPath(licenseStatus: LicenseStatus.expired);
      final built = buildCubit();
      await built.refresh();
      expect(built.state.license, LicenseStatusDisplay.invalid);
      expect(built.state.licenseDaysRemaining, isNull);
    });

    test('probe exception reports invalid', () async {
      when(() => licenseService.validate()).thenThrow(Exception('no file'));
      final built = buildCubit();
      await built.refresh();
      expect(built.state.license, LicenseStatusDisplay.invalid);
    });

    test('days remaining clear when the license is renewed', () async {
      stubHappyPath(license: licenseExpiringIn(3));
      final built = buildCubit();
      await built.refresh();
      expect(built.state.license, LicenseStatusDisplay.expiring);

      stubHappyPath(license: licenseExpiringIn(90));
      await built.refresh();
      expect(built.state.license, LicenseStatusDisplay.valid);
      expect(built.state.licenseDaysRemaining, isNull);
    });
  });

  group('lifecycle', () {
    test('close cancels the status subscription', () async {
      final built = buildCubit();
      await built.close();
      cubit = null;

      scaleController.add(
        const ScaleStatus(state: ScaleConnectionState.connected),
      );
      await Future<void>.delayed(Duration.zero);
      // No emission after close: state stays at the seeded value.
      expect(built.state.scale, ScaleStatusDisplay.disconnected);
    });
  });
}
