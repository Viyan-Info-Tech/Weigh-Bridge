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
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  @override
  List<Object?> get props => [id, billNumber, partyId, vehicleId, materialId, grossWeightKg, tareWeightKg, netWeightKg, vehicleCharge, amount, status];
}
