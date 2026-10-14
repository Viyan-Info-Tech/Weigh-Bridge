import 'package:equatable/equatable.dart';

enum DateRangePreset {
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  custom('Custom Range');

  final String label;
  const DateRangePreset(this.label);
}

class ReportFilter extends Equatable {
  /// How many records the report table requests per page.
  ///
  /// Bounds how much data crosses from SQLite into Dart, so opening a report
  /// over a large table costs the same as opening it over a small one.
  static const int defaultPageSize = 200;

  final DateRangePreset datePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String vehicleNumber;
  final String searchQuery;

  const ReportFilter({
    this.datePreset = DateRangePreset.today,
    this.customStartDate,
    this.customEndDate,
    this.vehicleNumber = '',
    this.searchQuery = '',
  });

  DateTime get effectiveStartDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (datePreset) {
      case DateRangePreset.today:
        return today;
      case DateRangePreset.yesterday:
        return today.subtract(const Duration(days: 1));
      case DateRangePreset.thisWeek:
        return today.subtract(Duration(days: now.weekday - 1));
      case DateRangePreset.thisMonth:
        return DateTime(now.year, now.month, 1);
      case DateRangePreset.lastMonth:
        return DateTime(now.year, now.month - 1, 1);
      case DateRangePreset.custom:
        return customStartDate != null
            ? DateTime(
                customStartDate!.year,
                customStartDate!.month,
                customStartDate!.day,
              )
            : today;
    }
  }

  DateTime get effectiveEndDate {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (datePreset) {
      case DateRangePreset.today:
        return todayEnd;
      case DateRangePreset.yesterday:
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        return DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          23,
          59,
          59,
          999,
        );
      case DateRangePreset.thisWeek:
        return todayEnd;
      case DateRangePreset.thisMonth:
        return todayEnd;
      case DateRangePreset.lastMonth:
        final lastDayOfPrevMonth = DateTime(
          now.year,
          now.month,
          0,
          23,
          59,
          59,
          999,
        );
        return lastDayOfPrevMonth;
      case DateRangePreset.custom:
        return customEndDate != null
            ? DateTime(
                customEndDate!.year,
                customEndDate!.month,
                customEndDate!.day,
                23,
                59,
                59,
                999,
              )
            : todayEnd;
    }
  }

  ReportFilter copyWith({
    DateRangePreset? datePreset,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? vehicleNumber,
    String? searchQuery,
    bool clearCustomDates = false,
  }) {
    return ReportFilter(
      datePreset: datePreset ?? this.datePreset,
      customStartDate: clearCustomDates
          ? null
          : (customStartDate ?? this.customStartDate),
      customEndDate: clearCustomDates
          ? null
          : (customEndDate ?? this.customEndDate),
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    datePreset,
    customStartDate,
    customEndDate,
    vehicleNumber,
    searchQuery,
  ];
}
