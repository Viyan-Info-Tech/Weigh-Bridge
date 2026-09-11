import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle.dart';

enum VehicleStatus { initial, loading, loaded, error, success }

class VehicleState extends Equatable {
  final VehicleStatus status;
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;
  final bool? filterActive;
  final int? filterPartyId;

  const VehicleState({
    this.status = VehicleStatus.initial,
    this.vehicles = const [],
    this.selectedVehicle,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
    this.filterActive,
    this.filterPartyId,
  });

  VehicleState copyWith({
    VehicleStatus? status,
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    bool? filterActive,
    int? filterPartyId,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive: filterActive ?? this.filterActive,
      filterPartyId: filterPartyId ?? this.filterPartyId,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, selectedVehicle, errorMessage, successMessage, searchQuery, filterActive, filterPartyId];
}
