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
  final DateRangePreset datePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final int? partyId;
  final int? vehicleId;
  final int? materialId;
  final String status; // 'all', 'completed', 'pending'
  final String paymentMode; // 'all', 'cash', 'credit'
  final String searchQuery;

  const ReportFilter({
    this.datePreset = DateRangePreset.today,
    this.customStartDate,
    this.customEndDate,
    this.partyId,
    this.vehicleId,
    this.materialId,
    this.status = 'all',
    this.paymentMode = 'all',
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
    int? partyId,
    int? vehicleId,
    int? materialId,
    String? status,
    String? paymentMode,
    String? searchQuery,
    bool clearParty = false,
    bool clearVehicle = false,
    bool clearMaterial = false,
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
      partyId: clearParty ? null : (partyId ?? this.partyId),
      vehicleId: clearVehicle ? null : (vehicleId ?? this.vehicleId),
      materialId: clearMaterial ? null : (materialId ?? this.materialId),
      status: status ?? this.status,
      paymentMode: paymentMode ?? this.paymentMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    datePreset,
    customStartDate,
    customEndDate,
    partyId,
    vehicleId,
    materialId,
    status,
    paymentMode,
    searchQuery,
  ];
}
