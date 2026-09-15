import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final int id;
  final String vehicleNumber;
  final int vehicleTypeId;
  final String? driverName;
  final String? driverPhone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleTypeId,
    this.driverName,
    this.driverPhone,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    vehicleNumber,
    vehicleTypeId,
    driverName,
    driverPhone,
    isActive,
  ];
}
