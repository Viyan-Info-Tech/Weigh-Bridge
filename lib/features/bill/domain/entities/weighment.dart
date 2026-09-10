import 'package:equatable/equatable.dart';

class Weighment extends Equatable {
  final int id;
  final String billNumber;
  final int partyId;
  final int vehicleId;
  final int materialId;
  final String entryType;
  final String paymentMode;
  final double firstWeightKg;
  final double secondWeightKg;
  final double netWeightKg;
  final double ratePerTon;
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
    required this.entryType,
    required this.paymentMode,
    required this.firstWeightKg,
    required this.secondWeightKg,
    required this.netWeightKg,
    required this.ratePerTon,
    required this.amount,
    this.remarks,
    this.status = 'completed',
    required this.createdAt,
    required this.updatedAt,
  });

  double get netWeightTon => netWeightKg / 1000;

  @override
  List<Object?> get props => [id, billNumber, partyId, vehicleId, materialId, netWeightKg, amount];
}
