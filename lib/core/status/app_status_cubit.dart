import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/app_database.dart';
import '../hardware/scale/domain/scale_service.dart';
import '../hardware/scale/domain/scale_status.dart';
import '../licensing/domain/enums/license_status.dart';
import '../licensing/license_service.dart';
import '../printing/print_service.dart';
import 'app_status_state.dart';

/// Maps a raw [ScaleStatus] onto the display state used by the status bar.
ScaleStatusDisplay mapScaleStatus(ScaleStatus status) {
  return switch (status.state) {
    ScaleConnectionState.connected =>
      status.stale ? ScaleStatusDisplay.stale : ScaleStatusDisplay.connected,
    ScaleConnectionState.connecting ||
    ScaleConnectionState.reconnecting => ScaleStatusDisplay.connecting,
    ScaleConnectionState.disconnected ||
    ScaleConnectionState.error => ScaleStatusDisplay.disconnected,
  };
}

/// Aggregates the health of scale, database, printer and license into a
/// single state stream consumed by the home status bar.
///
/// The scale is tracked live through [ScaleService.statusStream]; the other
/// probes are re-run on a fixed interval so the bar never goes stale.
class AppStatusCubit extends Cubit<AppStatusState> {
  AppStatusCubit({
    required ScaleService scaleService,
    required AppDatabase database,
    required PrintService printService,
    required LicenseService licenseService,
    Duration pollInterval = const Duration(seconds: 30),
    int expiringWithinDays = 7,
  }) : _scaleService = scaleService,
       _database = database,
       _printService = printService,
       _licenseService = licenseService,
       _expiringWithinDays = expiringWithinDays,
       super(
         AppStatusState(scale: mapScaleStatus(scaleService.currentStatus)),
       ) {
    _statusSubscription = _scaleService.statusStream.listen(
      (status) =>
          _update((state) => state.copyWith(scale: mapScaleStatus(status))),
    );
    refresh();
    _timer = Timer.periodic(pollInterval, (_) => refresh());
  }

  final ScaleService _scaleService;
  final AppDatabase _database;
  final PrintService _printService;
  final LicenseService _licenseService;
  final int _expiringWithinDays;

  StreamSubscription<ScaleStatus>? _statusSubscription;
  Timer? _timer;

  /// Re-runs every non-live probe (database, printer, license).
  Future<void> refresh() async {
    await Future.wait([
      _refreshDatabase(),
      _refreshPrinter(),
      _refreshLicense(),
    ]);
  }

  Future<void> _refreshDatabase() async {
    var display = DatabaseStatusDisplay.error;
    try {
      final healthy = await _database.healthCheck();
      display = healthy
          ? DatabaseStatusDisplay.open
          : DatabaseStatusDisplay.error;
    } catch (_) {
      display = DatabaseStatusDisplay.error;
    }
    _update((state) => state.copyWith(database: display));
  }

  Future<void> _refreshPrinter() async {
    var display = PrinterStatusDisplay.offline;
    try {
      final available = await _printService.isPrinterAvailable();
      display = available
          ? PrinterStatusDisplay.available
          : PrinterStatusDisplay.offline;
    } catch (_) {
      display = PrinterStatusDisplay.offline;
    }
    _update((state) => state.copyWith(printer: display));
  }

  Future<void> _refreshLicense() async {
    LicenseStatusDisplay display = LicenseStatusDisplay.invalid;
    int? daysRemaining;
    try {
      final status = await _licenseService.validate();
      if (status == LicenseStatus.valid) {
        final license = await _licenseService.loadLicense();
        if (license != null) {
          daysRemaining = license.expiresAt.difference(DateTime.now()).inDays;
        }
        final expiring =
            daysRemaining != null && daysRemaining <= _expiringWithinDays;
        display = expiring
            ? LicenseStatusDisplay.expiring
            : LicenseStatusDisplay.valid;
      }
    } catch (_) {
      display = LicenseStatusDisplay.invalid;
    }
    final expiring = display == LicenseStatusDisplay.expiring;
    _update(
      (state) => state.copyWith(
        license: display,
        licenseDaysRemaining: expiring ? daysRemaining : null,
        clearLicenseDaysRemaining: !expiring,
      ),
    );
  }

  void _update(AppStatusState Function(AppStatusState) updater) {
    if (isClosed) return;
    emit(updater(state));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    unawaited(_statusSubscription?.cancel());
    return super.close();
  }
}
