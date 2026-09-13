import 'package:equatable/equatable.dart';

class Weighment extends Equatable {
  final int id;
  final String billNumber;
  final int partyId;
  final int vehicleId;
  final int materialId;
  final String paymentMode;
  final double grossWeightKg;
  final double? tareWeightKg;
  final double? netWeightKg;
  final double vehicleCharge;
  final double amount;
  final String? remarks;
  final String status;
  final String firstWeightType;
  final String? secondWeightType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Weighment({
    required this.id,
    required this.billNumber,
    required this.partyId,
    required this.vehicleId,
    required this.materialId,
    required this.paymentMode,
    required this.grossWeightKg,
    this.tareWeightKg,
    this.netWeightKg,
    required this.vehicleCharge,
    required this.amount,
    this.remarks,
    this.status = 'pending',
    this.firstWeightType = 'GROSS',
    this.secondWeightType,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  double get firstWeightKg => grossWeightKg;
  double? get secondWeightKg => tareWeightKg;

  @override
  List<Object?> get props => [
        id,
        billNumber,
        partyId,
        vehicleId,
        materialId,
        grossWeightKg,
        tareWeightKg,
        netWeightKg,
        vehicleCharge,
        amount,
        status,
        firstWeightType,
        secondWeightType,
      ];
}
