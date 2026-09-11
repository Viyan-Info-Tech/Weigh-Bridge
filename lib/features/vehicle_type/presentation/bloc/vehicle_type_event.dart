import 'package:equatable/equatable.dart';

abstract class VehicleTypeEvent extends Equatable {
  const VehicleTypeEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicleTypes extends VehicleTypeEvent {
  final bool? filterActive;

  const LoadVehicleTypes({this.filterActive});

  @override
  List<Object?> get props => [filterActive];
}

class CreateVehicleTypeRequested extends VehicleTypeEvent {
  final String name;
  final double emptyPrice;
  final double loadPrice;

  const CreateVehicleTypeRequested({
    required this.name,
    this.emptyPrice = 0,
    this.loadPrice = 0,
  });

  @override
  List<Object?> get props => [name, emptyPrice, loadPrice];
}

class UpdateVehicleTypeRequested extends VehicleTypeEvent {
  final int id;
  final String name;
  final double emptyPrice;
  final double loadPrice;

  const UpdateVehicleTypeRequested({
    required this.id,
    required this.name,
    this.emptyPrice = 0,
    this.loadPrice = 0,
  });

  @override
  List<Object?> get props => [id, name, emptyPrice, loadPrice];
}

class DeactivateVehicleTypeRequested extends VehicleTypeEvent {
  final int vehicleTypeId;

  const DeactivateVehicleTypeRequested(this.vehicleTypeId);

  @override
  List<Object?> get props => [vehicleTypeId];
}

class SearchVehicleTypes extends VehicleTypeEvent {
  final String query;

  const SearchVehicleTypes(this.query);

  @override
  List<Object?> get props => [query];
}
