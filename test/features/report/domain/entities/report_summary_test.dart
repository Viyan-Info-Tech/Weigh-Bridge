import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';

void main() {
  test('defaults to all zeros', () {
    const summary = ReportSummary();
    expect(summary.totalBills, 0);
    expect(summary.totalGrossWeightKg, 0);
    expect(summary.totalTareWeightKg, 0);
    expect(summary.totalNetWeightKg, 0);
    expect(summary.completedCount, 0);
    expect(summary.totalCharges, 0);
  });

  test('formats the charges total with the rupee symbol', () {
    const summary = ReportSummary(totalCharges: 1250);
    expect(summary.totalChargesText, '₹ 1,250.00');
  });

  test('charges total with no charge reads as zero', () {
    const summary = ReportSummary();
    expect(summary.totalChargesText, '₹ 0.00');
  });

  test('formats gross weight as tons with 2 decimals', () {
    const summary = ReportSummary(totalGrossWeightKg: 1234567.89);
    expect(summary.totalGrossTons, '1234.57');
  });

  test('formats net weight as tons with 2 decimals', () {
    const summary = ReportSummary(totalNetWeightKg: 500);
    expect(summary.totalNetTons, '0.50');
  });

  test('equality is based on all fields', () {
    const a = ReportSummary(
      totalBills: 3,
      totalGrossWeightKg: 100,
      completedCount: 2,
    );
    const b = ReportSummary(
      totalBills: 3,
      totalGrossWeightKg: 100,
      completedCount: 2,
    );
    const c = ReportSummary(totalBills: 4);
    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
  });
}
