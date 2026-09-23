import 'package:equatable/equatable.dart';

import '../../../customer/domain/entities/customer.dart';
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

  final List<Customer> customers;
  final List<MaterialItem> materials;
  final List<Weighment> recentBills;
  final DateTime? billsDate;
  final DateTime? billsStartDate;
  final DateTime? billsEndDate;

  final Customer? selectedCustomer;
  final String vehicleNumber;
  final MaterialItem? selectedMaterial;

  final String paymentMode;

  final String grossWeightText;
  final String tareWeightText;
  final String remarksText;

  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;
  final double vehicleCharge;
  final double amount;

  final String currentBillNumber;
  final int? editingBillId;
  final String? editingFirstWeightType;
  final double? editingFirstWeightKg;
  final DateTime? editingBillCreatedAt;
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
  final Customer? printReceiptCustomer;
  final String? printReceiptMaterialName;

  const BillState({
    this.status = BillScreenStatus.initial,
    this.errorMessage,
    this.customers = const [],
    this.materials = const [],
    this.recentBills = const [],
    this.billsDate,
    this.billsStartDate,
    this.billsEndDate,
    this.selectedCustomer,
    this.vehicleNumber = '',
    this.selectedMaterial,
    this.paymentMode = 'Cash',
    this.grossWeightText = '',
    this.tareWeightText = '',
    this.remarksText = '',
    this.grossWeightKg = 0,
    this.tareWeightKg = 0,
    this.netWeightKg = 0,
    this.vehicleCharge = 0,
    this.amount = 0,
    this.currentBillNumber = 'WB-00001',
    this.editingBillId,
    this.editingFirstWeightType,
    this.editingFirstWeightKg,
    this.editingBillCreatedAt,
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
    this.printReceiptCustomer,
    this.printReceiptMaterialName,
  });

  bool get isEditing => editingBillId != null;
  bool get isCompleted => grossWeightKg > 0 && tareWeightKg > 0;
  bool get isKg => weightUnit.trim().toLowerCase() == 'kg';

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
    List<Customer>? customers,
    List<MaterialItem>? materials,
    List<Weighment>? recentBills,
    DateTime? billsDate,
    DateTime? billsStartDate,
    DateTime? billsEndDate,
    bool clearDateRange = false,
    Customer? selectedCustomer,
    bool clearCustomer = false,
    String? vehicleNumber,
    MaterialItem? selectedMaterial,
    bool clearMaterial = false,
    String? paymentMode,
    String? grossWeightText,
    String? tareWeightText,
    String? remarksText,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    double? vehicleCharge,
    double? amount,
    String? currentBillNumber,
    int? editingBillId,
    bool clearEditingBillId = false,
    String? editingFirstWeightType,
    double? editingFirstWeightKg,
    bool clearEditingFirstWeight = false,
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
    Weighment? printReceiptBill,
    Customer? printReceiptCustomer,
    String? printReceiptMaterialName,
    bool clearPrintReceipt = false,
    DateTime? editingBillCreatedAt,
    bool clearEditingBillCreatedAt = false,
  }) {
    return BillState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      customers: customers ?? this.customers,
      materials: materials ?? this.materials,
      recentBills: recentBills ?? this.recentBills,
      billsDate: billsDate ?? this.billsDate,
      billsStartDate: clearDateRange
          ? null
          : (billsStartDate ?? this.billsStartDate),
      billsEndDate: clearDateRange ? null : (billsEndDate ?? this.billsEndDate),
      selectedCustomer: clearCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      selectedMaterial: clearMaterial
          ? null
          : (selectedMaterial ?? this.selectedMaterial),
      paymentMode: paymentMode ?? this.paymentMode,
      grossWeightText: grossWeightText ?? this.grossWeightText,
      tareWeightText: tareWeightText ?? this.tareWeightText,
      remarksText: remarksText ?? this.remarksText,
      grossWeightKg: grossWeightKg ?? this.grossWeightKg,
      tareWeightKg: tareWeightKg ?? this.tareWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      vehicleCharge: vehicleCharge ?? this.vehicleCharge,
      amount: amount ?? this.amount,
      currentBillNumber: currentBillNumber ?? this.currentBillNumber,
      editingBillId: clearEditingBillId
          ? null
          : (editingBillId ?? this.editingBillId),
      editingFirstWeightType: clearEditingFirstWeight
          ? null
          : (editingFirstWeightType ?? this.editingFirstWeightType),
      editingFirstWeightKg: clearEditingFirstWeight
          ? null
          : (editingFirstWeightKg ?? this.editingFirstWeightKg),
      editingBillCreatedAt: clearEditingBillCreatedAt
          ? null
          : (editingBillCreatedAt ?? this.editingBillCreatedAt),
      weightValidationError: clearWeightError
          ? null
          : (weightValidationError ?? this.weightValidationError),
      weightUnit: weightUnit ?? this.weightUnit,
      liveScaleWeightKg: liveScaleWeightKg ?? this.liveScaleWeightKg,
      isScaleStable: isScaleStable ?? this.isScaleStable,
      isScaleMotion: isScaleMotion ?? this.isScaleMotion,
      isScaleOverload: isScaleOverload ?? this.isScaleOverload,
      selectedWeightType: selectedWeightType ?? this.selectedWeightType,
      grossCapturedAt: grossCapturedAt ?? this.grossCapturedAt,
      tareCapturedAt: tareCapturedAt ?? this.tareCapturedAt,
      printReceiptBill: clearPrintReceipt
          ? null
          : (printReceiptBill ?? this.printReceiptBill),
      printReceiptCustomer: clearPrintReceipt
          ? null
          : (printReceiptCustomer ?? this.printReceiptCustomer),
      printReceiptMaterialName: clearPrintReceipt
          ? null
          : (printReceiptMaterialName ?? this.printReceiptMaterialName),
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    customers,
    materials,
    recentBills,
    billsDate,
    billsStartDate,
    billsEndDate,
    selectedCustomer,
    vehicleNumber,
    selectedMaterial,
    paymentMode,
    grossWeightText,
    tareWeightText,
    remarksText,
    grossWeightKg,
    tareWeightKg,
    netWeightKg,
    vehicleCharge,
    amount,
    currentBillNumber,
    editingBillId,
    editingFirstWeightType,
    editingFirstWeightKg,
    editingBillCreatedAt,
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
    printReceiptCustomer,
    printReceiptMaterialName,
  ];
}
