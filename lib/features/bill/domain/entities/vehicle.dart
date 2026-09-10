import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final int id;
  final String vehicleNumber;
  final int partyId;
  final String? vehicleType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.partyId,
    this.vehicleType,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, vehicleNumber, partyId, vehicleType, isActive];
}
