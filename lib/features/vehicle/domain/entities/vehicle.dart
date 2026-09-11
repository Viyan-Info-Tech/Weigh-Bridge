import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final int id;
  final String vehicleNumber;
  final int partyId;
  final String? vehicleType;
  final String? driverName;
  final String? driverPhone;
  final double? tareWeight;
  final bool isActive;
  final String? vendorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.partyId,
    this.vehicleType,
    this.driverName,
    this.driverPhone,
    this.tareWeight,
    this.isActive = true,
    this.vendorName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, vehicleNumber, partyId, vehicleType, driverName, driverPhone, tareWeight, isActive, vendorName];
}
