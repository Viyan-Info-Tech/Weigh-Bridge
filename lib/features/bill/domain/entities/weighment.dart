import 'package:equatable/equatable.dart';

class Weighment extends Equatable {
  final int id;
  final String billNumber;
  final int partyId;
  final int vehicleId;
  final int materialId;
  final String paymentMode;
  final double firstWeightKg;
  final String firstWeightType;
  final double? secondWeightKg;
  final String? secondWeightType;
  final double? explicitNetWeightKg;
  final double vehicleCharge;
  final double amount;
  final String? remarks;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Weighment({
    required this.id,
    required this.billNumber,
    required this.partyId,
    required this.vehicleId,
    required this.materialId,
    required this.paymentMode,
    double? firstWeightKg,
    this.firstWeightType = 'GROSS',
    this.secondWeightKg,
    this.secondWeightType,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    required this.vehicleCharge,
    required this.amount,
    this.remarks,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  })  : firstWeightKg = firstWeightKg ??
            ((firstWeightType == 'TARE' || firstWeightType == 'tare')
                ? (tareWeightKg ?? 0)
                : (grossWeightKg ?? 0)),
        explicitNetWeightKg = netWeightKg;

  bool get isCompleted =>
      status.toLowerCase() == 'completed' ||
      (firstWeightKg > 0 && secondWeightKg != null && secondWeightKg! > 0);

  bool get isPending => !isCompleted;

  /// Business Logic for Gross Weight:
  /// If firstWeightType == GROSS -> firstWeight (if > 0)
  /// If firstWeightType == TARE -> secondWeight (if available > 0, else null)
  double? get grossWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'GROSS') {
      return firstWeightKg > 0 ? firstWeightKg : null;
    } else if (type == 'TARE') {
      return (secondWeightKg != null && secondWeightKg! > 0) ? secondWeightKg : null;
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
      return (secondWeightKg != null && secondWeightKg! > 0) ? secondWeightKg : null;
    }
    return (secondWeightKg != null && secondWeightKg! > 0) ? secondWeightKg : null;
  }

  /// Net Weight:
  /// (gross - tare).abs() when both exist
  double? get netWeightKg {
    if (explicitNetWeightKg != null && explicitNetWeightKg! > 0) {
      return explicitNetWeightKg;
    }
    final g = grossWeightKg;
    final t = tareWeightKg;
    if (g != null && t != null && g > 0 && t > 0) {
      return (g - t).abs();
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        billNumber,
        partyId,
        vehicleId,
        materialId,
        firstWeightKg,
        firstWeightType,
        secondWeightKg,
        secondWeightType,
        explicitNetWeightKg,
        vehicleCharge,
        amount,
        status,
        createdAt,
        updatedAt,
      ];
}
