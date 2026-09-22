import 'package:equatable/equatable.dart';

class WeighmentReportItem extends Equatable {
  final int id;
  final String billNumber;
  final DateTime createdAt;
  final String vehicleNumber;
  final int customerId;
  final String customerName;
  final int materialId;
  final String materialName;
  final String paymentMode;
  final double amount;
  final double vehicleCharge;
  final String? remarks;
  final double firstWeightKg;
  final String firstWeightType;
  final double? secondWeightKg;
  final String? secondWeightType;
  final String weightUnit;

  const WeighmentReportItem({
    required this.id,
    required this.billNumber,
    required this.createdAt,
    required this.vehicleNumber,
    required this.customerId,
    required this.customerName,
    required this.materialId,
    required this.materialName,
    required this.paymentMode,
    required this.amount,
    required this.vehicleCharge,
    this.remarks,
    required this.firstWeightKg,
    this.firstWeightType = 'GROSS',
    this.secondWeightKg,
    this.secondWeightType,
    this.weightUnit = 'ton',
  });

  /// Business Logic for Gross Weight:
  /// If firstWeightType == GROSS -> firstWeight (if > 0)
  /// If firstWeightType == TARE -> secondWeight (if available > 0, else null)
  double? get grossWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'GROSS') {
      return firstWeightKg > 0 ? firstWeightKg : null;
    } else if (type == 'TARE') {
      return (secondWeightKg != null && secondWeightKg! > 0)
          ? secondWeightKg
          : null;
    }
    return firstWeightKg > 0 ? firstWeightKg : null;
  }

  /// Business Logic for Tare Weight:
  /// If firstWeightType == TARE -> firstWeight (if > 0)
  /// If firstWeightType == GROSS -> secondWeight (if available > 0, else null)
  double? get tareWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'TARE') {
      return firstWeightKg > 0 ? firstWeightKg : null;
    } else if (type == 'GROSS') {
      return (secondWeightKg != null && secondWeightKg! > 0)
          ? secondWeightKg
          : null;
    }
    return (secondWeightKg != null && secondWeightKg! > 0)
        ? secondWeightKg
        : null;
  }

  /// Net Weight is only calculated when both Gross and Tare weights exist:
  /// netWeight = grossWeight - tareWeight
  double? get netWeightKg {
    final gross = grossWeightKg;
    final tare = tareWeightKg;
    if (gross != null && tare != null && gross > 0 && tare > 0) {
      return (gross - tare).abs();
    }
    return null;
  }

  /// A weighment is completed once both weights have been captured.
  bool get isCompleted =>
      firstWeightKg > 0 && secondWeightKg != null && secondWeightKg! > 0;

  @override
  List<Object?> get props => [
    id,
    billNumber,
    createdAt,
    vehicleNumber,
    customerId,
    customerName,
    materialId,
    materialName,
    paymentMode,
    amount,
    vehicleCharge,
    remarks,
    firstWeightKg,
    firstWeightType,
    secondWeightKg,
    secondWeightType,
    weightUnit,
  ];
}
