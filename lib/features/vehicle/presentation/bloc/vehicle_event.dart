import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {
  final String? searchQuery;
  final bool? filterActive;

  const LoadVehicles({this.searchQuery, this.filterActive});

  @override
  List<Object?> get props => [searchQuery, filterActive];
}

class CreateVehicleRequested extends VehicleEvent {
  final String vehicleNumber;
  final int vehicleTypeId;
  final String? driverName;
  final String? driverPhone;

  const CreateVehicleRequested({
    required this.vehicleNumber,
    required this.vehicleTypeId,
    this.driverName,
    this.driverPhone,
  });

  @override
  List<Object?> get props => [vehicleNumber, vehicleTypeId, driverName, driverPhone];
}

class UpdateVehicleRequested extends VehicleEvent {
  final int id;
  final String vehicleNumber;
  final int vehicleTypeId;
  final String? driverName;
  final String? driverPhone;

  const UpdateVehicleRequested({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleTypeId,
    this.driverName,
    this.driverPhone,
  });

  @override
  List<Object?> get props => [id, vehicleNumber, vehicleTypeId, driverName, driverPhone];
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
