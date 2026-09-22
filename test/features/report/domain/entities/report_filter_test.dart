import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('defaults', () {
    test('uses today, all modes and empty search', () {
      const filter = ReportFilter();
      expect(filter.datePreset, DateRangePreset.today);
      expect(filter.paymentMode, 'all');
      expect(filter.searchQuery, '');
      expect(filter.customerId, isNull);
      expect(filter.vehicleNumber, '');
      expect(filter.materialId, isNull);
    });
  });

  group('effectiveStartDate', () {
    test('today starts at midnight', () {
      const filter = ReportFilter(datePreset: DateRangePreset.today);
      expect(filter.effectiveStartDate, today);
    });

    test('yesterday starts at midnight of the previous day', () {
      const filter = ReportFilter(datePreset: DateRangePreset.yesterday);
      expect(
        filter.effectiveStartDate,
        today.subtract(const Duration(days: 1)),
      );
    });

    test('thisWeek starts at the beginning of the current week', () {
      const filter = ReportFilter(datePreset: DateRangePreset.thisWeek);
      expect(
        filter.effectiveStartDate,
        today.subtract(Duration(days: now.weekday - 1)),
      );
    });

    test('thisMonth starts on the first of the month', () {
      const filter = ReportFilter(datePreset: DateRangePreset.thisMonth);
      expect(filter.effectiveStartDate, DateTime(now.year, now.month, 1));
    });

    test('lastMonth starts on the first of the previous month', () {
      const filter = ReportFilter(datePreset: DateRangePreset.lastMonth);
      expect(filter.effectiveStartDate, DateTime(now.year, now.month - 1, 1));
    });

    test('custom uses the custom start date, normalized to midnight', () {
      final filter = ReportFilter(
        datePreset: DateRangePreset.custom,
        customStartDate: DateTime(2026, 9, 1, 14, 30),
        customEndDate: DateTime(2026, 9, 13, 23, 59),
      );
      expect(filter.effectiveStartDate, DateTime(2026, 9, 1));
    });
  });

  group('effectiveEndDate', () {
    test('today ends at the end of the day', () {
      const filter = ReportFilter(datePreset: DateRangePreset.today);
      expect(
        filter.effectiveEndDate,
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
      );
    });

    test('lastMonth ends on the last day of the previous month', () {
      const filter = ReportFilter(datePreset: DateRangePreset.lastMonth);
      final lastDay = DateTime(now.year, now.month, 0);
      expect(
        filter.effectiveEndDate,
        DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59, 999),
      );
    });

    test('custom uses the custom end date, normalized to end of day', () {
      final filter = ReportFilter(
        datePreset: DateRangePreset.custom,
        customStartDate: DateTime(2026, 9, 1),
        customEndDate: DateTime(2026, 9, 13, 8, 0),
      );
      expect(filter.effectiveEndDate, DateTime(2026, 9, 13, 23, 59, 59, 999));
    });
  });

  group('copyWith', () {
    final filter = ReportFilter(
      datePreset: DateRangePreset.custom,
      customStartDate: DateTime(2026, 9, 1),
      customEndDate: DateTime(2026, 9, 13),
      customerId: 5,
      vehicleNumber: 'KA01AB2345',
      materialId: 2,
      paymentMode: 'cash',
      searchQuery: 'TN',
    );

    test('updates individual fields', () {
      final updated = filter.copyWith(searchQuery: 'KA');
      expect(updated.searchQuery, 'KA');
      expect(updated.customerId, 5);
      expect(updated.datePreset, DateRangePreset.custom);
    });

    test('clears relational filters with clear flags', () {
      final cleared = filter.copyWith(clearCustomer: true, clearMaterial: true);
      expect(cleared.customerId, isNull);
      expect(cleared.materialId, isNull);
    });

    test('clears custom dates with clearCustomDates', () {
      final cleared = filter.copyWith(clearCustomDates: true);
      expect(cleared.customStartDate, isNull);
      expect(cleared.customEndDate, isNull);
    });

    test('is a copy, not the original', () {
      final updated = filter.copyWith();
      expect(updated, equals(filter));
      expect(updated, isNot(same(filter)));
    });
  });
}
