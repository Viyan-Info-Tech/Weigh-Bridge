import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_tare_record.dart';
import '../../domain/entities/weighment.dart';

enum BillScreenStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  printing,
  error,
}

class BillState extends Equatable {
  final BillScreenStatus status;
  final String? errorMessage;

  final List<Weighment> recentBills;
  final DateTime? billsDate;
  final DateTime? billsStartDate;
  final DateTime? billsEndDate;

  final String vehicleNumber;

  final String mobileNumber;

  final String grossWeightText;
  final String tareWeightText;
  final String remarksText;

  /// Free-text Material typed on the weighment form (TL redesign).
  final String materialText;

  /// Free-text Description typed on the weighment form (TL redesign).
  final String descriptionText;

  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;

  final String currentBillNumber;
  final int formResetRevision;

  /// Which weight ('GROSS' or 'TARE') was captured first on the active bill.
  ///
  /// The bill screen always represents a *new* bill, so this only describes
  /// what the operator has entered so far. It never refers to a saved record:
  /// completed bills are immutable history and are never loaded into this form.
  final String? firstWeightType;
  final String? weightValidationError;
  final String weightUnit;

  final double liveScaleWeightKg;
  final bool isScaleStable;
  final bool isScaleMotion;
  final bool isScaleOverload;
  final String selectedWeightType;
  final DateTime? grossCapturedAt;
  final DateTime? tareCapturedAt;

  /// Common/platform tare configured for the current day (F3). Zero means
  /// "Not Set"; it is never inherited from a previous day.
  final double autoTareKg;
  final DateTime? autoTareDate;
  final DateTime? autoTareSavedAt;

  /// Per-vehicle tare registry shown in the Auto Tare popup. Never cleared
  /// by form resets: it is reference data, not the in-progress weighment.
  final List<VehicleTareRecord> vehicleTareRecords;

  final Weighment? printReceiptBill;
  final Map<String, String> fieldErrors;

  const BillState({
    this.status = BillScreenStatus.initial,
    this.errorMessage,
    this.recentBills = const [],
    this.billsDate,
    this.billsStartDate,
    this.billsEndDate,
    this.vehicleNumber = '',
    this.mobileNumber = '',
    this.grossWeightText = '',
    this.tareWeightText = '',
    this.remarksText = '',
    this.materialText = '',
    this.descriptionText = '',
    this.grossWeightKg = 0,
    this.tareWeightKg = 0,
    this.netWeightKg = 0,
    this.currentBillNumber = 'WB-00001',
    this.formResetRevision = 0,
    this.firstWeightType,
    this.weightValidationError,
    this.weightUnit = 'kg',
    this.liveScaleWeightKg = 0,
    this.isScaleStable = false,
    this.isScaleMotion = false,
    this.isScaleOverload = false,
    this.selectedWeightType = 'Gross',
    this.grossCapturedAt,
    this.tareCapturedAt,
    this.autoTareKg = 0,
    this.autoTareDate,
    this.autoTareSavedAt,
    this.vehicleTareRecords = const [],
    this.printReceiptBill,
    this.fieldErrors = const {},
  });

  bool get hasBothWeights => grossWeightKg > 0 && tareWeightKg > 0;
  bool get isKg => weightUnit.trim().toLowerCase() == 'kg';

  /// A weight counts as captured only once it is a usable positive number.
  /// NaN and negatives are rejected by validation and must not be read as
  /// "present" here.
  bool get hasGrossWeight => grossWeightKg.isFinite && grossWeightKg > 0;
  bool get hasTareWeight => tareWeightKg.isFinite && tareWeightKg > 0;

  /// True when the truck has been weighed empty and will not return for a gross.
  ///
  /// Derived from the captured weights rather than from the GROSS/TARE toggle,
  /// because the toggle only says which weight is being captured *right now*.
  bool get isTareOnly => hasTareWeight && !hasGrossWeight;

  String? get vehicleNumberError => fieldErrors['vehicleNumber'];
  String? get weightError => fieldErrors['weight'] ?? weightValidationError;
  String? get mobileError => fieldErrors['mobile'];
  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  DateTime get effectiveBillsDate {
    final d = billsDate ?? DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }

  bool get isViewingTodaysBills {
    final now = DateTime.now();
    final d = effectiveBillsDate;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool get hasDateRange => billsStartDate != null || billsEndDate != null;
  bool get hasWeightError => weightValidationError != null;
  bool get hasAutoTare => autoTareKg.isFinite && autoTareKg > 0;

  BillState copyWith({
    BillScreenStatus? status,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? fieldErrors,
    bool clearFieldErrors = false,
    List<Weighment>? recentBills,
    DateTime? billsDate,
    DateTime? billsStartDate,
    DateTime? billsEndDate,
    bool clearDateRange = false,
    String? vehicleNumber,
    String? mobileNumber,
    String? grossWeightText,
    String? tareWeightText,
    String? remarksText,
    String? materialText,
    String? descriptionText,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    String? currentBillNumber,
    int? formResetRevision,
    String? firstWeightType,
    bool clearFirstWeightType = false,
    String? weightValidationError,
    bool clearWeightError = false,
    String? weightUnit,
    double? liveScaleWeightKg,
    bool? isScaleStable,
    bool? isScaleMotion,
    bool? isScaleOverload,
    String? selectedWeightType,
    DateTime? grossCapturedAt,
    DateTime? tareCapturedAt,
    bool clearGrossCapturedAt = false,
    bool clearTareCapturedAt = false,
    double? autoTareKg,
    DateTime? autoTareDate,
    DateTime? autoTareSavedAt,
    bool clearAutoTare = false,
    List<VehicleTareRecord>? vehicleTareRecords,
    Weighment? printReceiptBill,
    bool clearPrintReceipt = false,
  }) {
    return BillState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recentBills: recentBills ?? this.recentBills,
      billsDate: billsDate ?? this.billsDate,
      billsStartDate: clearDateRange
          ? null
          : (billsStartDate ?? this.billsStartDate),
      billsEndDate: clearDateRange ? null : (billsEndDate ?? this.billsEndDate),
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      grossWeightText: grossWeightText ?? this.grossWeightText,
      tareWeightText: tareWeightText ?? this.tareWeightText,
      remarksText: remarksText ?? this.remarksText,
      materialText: materialText ?? this.materialText,
      descriptionText: descriptionText ?? this.descriptionText,
      grossWeightKg: grossWeightKg ?? this.grossWeightKg,
      tareWeightKg: tareWeightKg ?? this.tareWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      currentBillNumber: currentBillNumber ?? this.currentBillNumber,
      formResetRevision: formResetRevision ?? this.formResetRevision,
      firstWeightType: clearFirstWeightType
          ? null
          : (firstWeightType ?? this.firstWeightType),
      weightValidationError: clearWeightError
          ? null
          : (weightValidationError ?? this.weightValidationError),
      weightUnit: weightUnit ?? this.weightUnit,
      liveScaleWeightKg: liveScaleWeightKg ?? this.liveScaleWeightKg,
      isScaleStable: isScaleStable ?? this.isScaleStable,
      isScaleMotion: isScaleMotion ?? this.isScaleMotion,
      isScaleOverload: isScaleOverload ?? this.isScaleOverload,
      selectedWeightType: selectedWeightType ?? this.selectedWeightType,
      grossCapturedAt: clearGrossCapturedAt
          ? null
          : (grossCapturedAt ?? this.grossCapturedAt),
      tareCapturedAt: clearTareCapturedAt
          ? null
          : (tareCapturedAt ?? this.tareCapturedAt),
      autoTareKg: clearAutoTare ? 0 : (autoTareKg ?? this.autoTareKg),
      autoTareDate: clearAutoTare ? null : (autoTareDate ?? this.autoTareDate),
      autoTareSavedAt: clearAutoTare
          ? null
          : (autoTareSavedAt ?? this.autoTareSavedAt),
      vehicleTareRecords: vehicleTareRecords ?? this.vehicleTareRecords,
      printReceiptBill: clearPrintReceipt
          ? null
          : (printReceiptBill ?? this.printReceiptBill),
      fieldErrors: clearFieldErrors
          ? const {}
          : (fieldErrors ?? this.fieldErrors),
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    recentBills,
    billsDate,
    billsStartDate,
    billsEndDate,
    vehicleNumber,
    mobileNumber,
    grossWeightText,
    tareWeightText,
    remarksText,
    materialText,
    descriptionText,
    grossWeightKg,
    tareWeightKg,
    netWeightKg,
    currentBillNumber,
    formResetRevision,
    firstWeightType,
    weightValidationError,
    weightUnit,
    liveScaleWeightKg,
    isScaleStable,
    isScaleMotion,
    isScaleOverload,
    selectedWeightType,
    grossCapturedAt,
    tareCapturedAt,
    autoTareKg,
    autoTareDate,
    autoTareSavedAt,
    vehicleTareRecords,
    printReceiptBill,
    fieldErrors,
  ];
}
