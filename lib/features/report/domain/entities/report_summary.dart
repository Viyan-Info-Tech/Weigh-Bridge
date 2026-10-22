import 'package:equatable/equatable.dart';

import '../../../../core/utils/currency_formatter.dart';

class ReportSummary extends Equatable {
  final int totalBills;
  final double totalGrossWeightKg;
  final double totalTareWeightKg;
  final double totalNetWeightKg;
  final int completedCount;

  /// Sum of the manually entered charges across every filtered record.
  ///
  /// Rows without a charge (legacy weighments) contribute zero, matching how
  /// the table displays them.
  final double totalCharges;

  const ReportSummary({
    this.totalBills = 0,
    this.totalGrossWeightKg = 0,
    this.totalTareWeightKg = 0,
    this.totalNetWeightKg = 0,
    this.completedCount = 0,
    this.totalCharges = 0,
  });

  String get totalGrossTons => (totalGrossWeightKg / 1000).toStringAsFixed(2);
  String get totalNetTons => (totalNetWeightKg / 1000).toStringAsFixed(2);

  /// Total charges rendered for the summary bar, e.g. `₹ 1,250.00`.
  String get totalChargesText =>
      '$currencySymbol ${formatChargesAmount(totalCharges)}';

  @override
  List<Object?> get props => [
    totalBills,
    totalGrossWeightKg,
    totalTareWeightKg,
    totalNetWeightKg,
    completedCount,
    totalCharges,
  ];
}
