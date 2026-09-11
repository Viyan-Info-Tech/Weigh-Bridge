import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_type.dart';

enum VehicleTypeStatus { initial, loading, loaded, error, success }

class VehicleTypeState extends Equatable {
  final VehicleTypeStatus status;
  final List<VehicleType> vehicleTypes;
  final VehicleType? selectedVehicleType;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;

  const VehicleTypeState({
    this.status = VehicleTypeStatus.initial,
    this.vehicleTypes = const [],
    this.selectedVehicleType,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
  });

  VehicleTypeState copyWith({
    VehicleTypeStatus? status,
    List<VehicleType>? vehicleTypes,
    VehicleType? selectedVehicleType,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
  }) {
    return VehicleTypeState(
      status: status ?? this.status,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, vehicleTypes, selectedVehicleType, errorMessage, successMessage, searchQuery];
}
