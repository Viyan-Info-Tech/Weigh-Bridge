import 'package:equatable/equatable.dart';

class WeighmentReportItem extends Equatable {
  final int id;
  final String billNumber;
  final DateTime createdAt;
  final int vehicleId;
  final String vehicleNumber;
  final String vehicleTypeName;
  final int partyId;
  final String partyName;
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
  final String rawStatus;

  const WeighmentReportItem({
    required this.id,
    required this.billNumber,
    required this.createdAt,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleTypeName,
    required this.partyId,
    required this.partyName,
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
    required this.rawStatus,
  });

  /// Business Logic for Gross Weight:
  /// If firstWeightType == GROSS -> firstWeight
  /// If firstWeightType == TARE -> secondWeight
  double? get grossWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'GROSS') {
      return firstWeightKg;
    } else if (type == 'TARE') {
      return secondWeightKg;
    }
    return firstWeightKg;
  }

  /// Business Logic for Tare Weight:
  /// If firstWeightType == TARE -> firstWeight
  /// If firstWeightType == GROSS -> secondWeight
  double? get tareWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'TARE') {
      return firstWeightKg;
    } else if (type == 'GROSS') {
      return secondWeightKg;
    }
    return secondWeightKg;
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

  /// Status logic:
  /// No weight -> DRAFT
  /// First weight only ->
  ///   If First == GROSS, Second missing -> TARE WEIGHT PENDING
  ///   If First == TARE, Second missing -> GROSS WEIGHT PENDING
  /// Second weight entered -> COMPLETED
  String get displayStatus {
    final hasSecond = secondWeightKg != null && secondWeightKg! > 0;
    if (firstWeightKg > 0 && hasSecond) {
      return 'COMPLETED';
    }
    if (firstWeightKg > 0 && !hasSecond) {
      final type = firstWeightType.toUpperCase();
      if (type == 'TARE') {
        return 'GROSS WEIGHT PENDING';
      }
      return 'TARE WEIGHT PENDING';
    }
    return 'DRAFT';
  }

  bool get isCompleted => displayStatus == 'COMPLETED';
  bool get isPending => !isCompleted;

  @override
  List<Object?> get props => [
        id,
        billNumber,
        createdAt,
        vehicleId,
        vehicleNumber,
        vehicleTypeName,
        partyId,
        partyName,
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
        rawStatus,
      ];
}
