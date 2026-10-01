import 'package:equatable/equatable.dart';

/// Display-ready connection state of the weigh scale.
enum ScaleStatusDisplay { checking, connected, stale, connecting, disconnected }

/// Display-ready health of the local database.
enum DatabaseStatusDisplay { checking, open, error }

/// Display-ready availability of a system printer.
enum PrinterStatusDisplay { checking, available, offline }

/// Display-ready validity of the installed license.
enum LicenseStatusDisplay { checking, valid, expiring, invalid }

/// Aggregated health of everything the home status bar reports.
class AppStatusState extends Equatable {
  const AppStatusState({
    this.scale = ScaleStatusDisplay.checking,
    this.database = DatabaseStatusDisplay.checking,
    this.printer = PrinterStatusDisplay.checking,
    this.license = LicenseStatusDisplay.checking,
    this.licenseDaysRemaining,
  });

  final ScaleStatusDisplay scale;
  final DatabaseStatusDisplay database;
  final PrinterStatusDisplay printer;
  final LicenseStatusDisplay license;

  /// Days left until the license expires, present only while [license] is
  /// [LicenseStatusDisplay.expiring].
  final int? licenseDaysRemaining;

  AppStatusState copyWith({
    ScaleStatusDisplay? scale,
    DatabaseStatusDisplay? database,
    PrinterStatusDisplay? printer,
    LicenseStatusDisplay? license,
    int? licenseDaysRemaining,
    bool clearLicenseDaysRemaining = false,
  }) {
    return AppStatusState(
      scale: scale ?? this.scale,
      database: database ?? this.database,
      printer: printer ?? this.printer,
      license: license ?? this.license,
      licenseDaysRemaining: clearLicenseDaysRemaining
          ? null
          : (licenseDaysRemaining ?? this.licenseDaysRemaining),
    );
  }

  @override
  List<Object?> get props => [
    scale,
    database,
    printer,
    license,
    licenseDaysRemaining,
  ];
}
