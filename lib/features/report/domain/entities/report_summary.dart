import 'package:equatable/equatable.dart';

class ReportSummary extends Equatable {
  final int totalBills;
  final double totalGrossWeightKg;
  final double totalTareWeightKg;
  final double totalNetWeightKg;
  final double totalRevenue;
  final int completedCount;

  const ReportSummary({
    this.totalBills = 0,
    this.totalGrossWeightKg = 0,
    this.totalTareWeightKg = 0,
    this.totalNetWeightKg = 0,
    this.totalRevenue = 0,
    this.completedCount = 0,
  });

  String get totalGrossTons => (totalGrossWeightKg / 1000).toStringAsFixed(2);
  String get totalNetTons => (totalNetWeightKg / 1000).toStringAsFixed(2);

  @override
  List<Object?> get props => [
    totalBills,
    totalGrossWeightKg,
    totalTareWeightKg,
    totalNetWeightKg,
    totalRevenue,
    completedCount,
  ];
}
