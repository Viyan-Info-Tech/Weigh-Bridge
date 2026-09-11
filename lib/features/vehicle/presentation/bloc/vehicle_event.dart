import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {
  final String? searchQuery;
  final bool? filterActive;
  final int? filterPartyId;

  const LoadVehicles({this.searchQuery, this.filterActive, this.filterPartyId});

  @override
  List<Object?> get props => [searchQuery, filterActive, filterPartyId];
}

class CreateVehicleRequested extends VehicleEvent {
  final String vehicleNumber;
  final int partyId;
  final String? vehicleType;
  final String? driverName;
  final String? driverPhone;
  final double? tareWeight;

  const CreateVehicleRequested({
    required this.vehicleNumber,
    required this.partyId,
    this.vehicleType,
    this.driverName,
    this.driverPhone,
    this.tareWeight,
  });

  @override
  List<Object?> get props => [vehicleNumber, partyId, vehicleType, driverName, driverPhone, tareWeight];
}

class UpdateVehicleRequested extends VehicleEvent {
  final int id;
  final String vehicleNumber;
  final int partyId;
  final String? vehicleType;
  final String? driverName;
  final String? driverPhone;
  final double? tareWeight;

  const UpdateVehicleRequested({
    required this.id,
    required this.vehicleNumber,
    required this.partyId,
    this.vehicleType,
    this.driverName,
    this.driverPhone,
    this.tareWeight,
  });

  @override
  List<Object?> get props => [id, vehicleNumber, partyId, vehicleType, driverName, driverPhone, tareWeight];
}

class DeactivateVehicleRequested extends VehicleEvent {
  final int vehicleId;

  const DeactivateVehicleRequested(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class SearchVehicles extends VehicleEvent {
  final String query;

  const SearchVehicles(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterVehiclesByStatus extends VehicleEvent {
  final bool? isActive;

  const FilterVehiclesByStatus(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class LoadVehicleById extends VehicleEvent {
  final int vehicleId;

  const LoadVehicleById(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}
