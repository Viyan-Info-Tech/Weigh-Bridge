import 'package:equatable/equatable.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../material/domain/entities/material_item.dart';
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
  ///
  /// Since the material dropdown was introduced this holds the display value
  /// of the selected option (e.g. `Auto - Empty`), not operator input.
  final String materialText;

  /// Active material master entries offered by the Material dropdown,
  /// loaded from the database.
  final List<MaterialItem> materialOptions;

  /// Id of the material master row selected on the form; its display value
  /// is mirrored in [materialText].
  final int? selectedMaterialId;

  /// Raw Charges text typed on the weighment form.
  ///
  /// Kept as text so the operator's in-progress input (including a trailing
  /// decimal point like `250.`) survives every keystroke. The parsed value is
  /// persisted once the bill is saved; empty text means "no charges" (NULL).
  final String chargesText;

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
    this.materialOptions = const [],
    this.selectedMaterialId,
    this.chargesText = '',
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
  String? get chargesError => fieldErrors['charges'];
  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  /// Charges parsed from [chargesText]; null when the field is empty.
  double? get charges {
    final parsed = parseChargesInput(chargesText);
    return parsed;
  }

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
    List<MaterialItem>? materialOptions,
    int? selectedMaterialId,
    bool clearSelectedMaterialId = false,
    String? chargesText,
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
      materialOptions: materialOptions ?? this.materialOptions,
      selectedMaterialId: clearSelectedMaterialId
          ? null
          : (selectedMaterialId ?? this.selectedMaterialId),
      chargesText: chargesText ?? this.chargesText,
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
    materialOptions,
    selectedMaterialId,
    chargesText,
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
    printReceiptBill,
    fieldErrors,
  ];
}
