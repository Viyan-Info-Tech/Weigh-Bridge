import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/load_vehicle_types.dart';
import '../../domain/usecases/create_vehicle_type.dart';
import '../../domain/usecases/delete_vehicle_type.dart';
import '../../domain/repositories/vehicle_type_repository.dart';
import 'vehicle_type_event.dart';
import 'vehicle_type_state.dart';

class VehicleTypeBloc extends Bloc<VehicleTypeEvent, VehicleTypeState> {
  final LoadVehicleTypesUseCase _loadVehicleTypesUseCase;
  final CreateVehicleTypeUseCase _createVehicleTypeUseCase;
  final DeleteVehicleTypeUseCase _deleteVehicleTypeUseCase;
  final VehicleTypeRepository _vehicleTypeRepository;

  VehicleTypeBloc({
    required LoadVehicleTypesUseCase loadVehicleTypesUseCase,
    required CreateVehicleTypeUseCase createVehicleTypeUseCase,
    required DeleteVehicleTypeUseCase deleteVehicleTypeUseCase,
    required VehicleTypeRepository vehicleTypeRepository,
  }) : _loadVehicleTypesUseCase = loadVehicleTypesUseCase,
       _createVehicleTypeUseCase = createVehicleTypeUseCase,
       _deleteVehicleTypeUseCase = deleteVehicleTypeUseCase,
       _vehicleTypeRepository = vehicleTypeRepository,
       super(const VehicleTypeState()) {
    on<LoadVehicleTypes>(_onLoadVehicleTypes);
    on<CreateVehicleTypeRequested>(_onCreateVehicleType);
    on<UpdateVehicleTypeRequested>(_onUpdateVehicleType);
    on<DeactivateVehicleTypeRequested>(_onDeactivateVehicleType);
    on<DeleteVehicleTypeRequested>(_onDeleteVehicleType);
    on<SearchVehicleTypes>(_onSearchVehicleTypes);
  }

  Future<void> _onLoadVehicleTypes(
    LoadVehicleTypes event,
    Emitter<VehicleTypeState> emit,
  ) async {
    emit(state.copyWith(status: VehicleTypeStatus.loading));
    try {
      final vehicleTypes = await _loadVehicleTypesUseCase(
        isActive: event.filterActive,
      );
      emit(
        state.copyWith(
          status: VehicleTypeStatus.loaded,
          vehicleTypes: vehicleTypes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VehicleTypeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateVehicleType(
    CreateVehicleTypeRequested event,
    Emitter<VehicleTypeState> emit,
  ) async {
    emit(state.copyWith(status: VehicleTypeStatus.loading));
    try {
      await _createVehicleTypeUseCase(
        name: event.name,
        emptyPrice: event.emptyPrice,
        loadPrice: event.loadPrice,
      );
      emit(
        state.copyWith(
          status: VehicleTypeStatus.success,
          successMessage: 'Vehicle type created successfully',
        ),
      );
      add(const LoadVehicleTypes());
    } catch (e) {
      emit(
        state.copyWith(
          status: VehicleTypeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateVehicleType(
    UpdateVehicleTypeRequested event,
    Emitter<VehicleTypeState> emit,
  ) async {
    emit(state.copyWith(status: VehicleTypeStatus.loading));
    try {
      await _vehicleTypeRepository.updateVehicleType(
        id: event.id,
        name: event.name,
        emptyPrice: event.emptyPrice,
        loadPrice: event.loadPrice,
      );
      emit(
        state.copyWith(
          status: VehicleTypeStatus.success,
          successMessage: 'Vehicle type updated successfully',
        ),
      );
      add(const LoadVehicleTypes());
    } catch (e) {
      emit(
        state.copyWith(
          status: VehicleTypeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeactivateVehicleType(
    DeactivateVehicleTypeRequested event,
    Emitter<VehicleTypeState> emit,
  ) async {
    emit(state.copyWith(status: VehicleTypeStatus.loading));
    try {
      await _vehicleTypeRepository.deactivateVehicleType(event.vehicleTypeId);
      emit(
        state.copyWith(
          status: VehicleTypeStatus.success,
          successMessage: 'Vehicle type deactivated',
        ),
      );
      add(const LoadVehicleTypes());
    } catch (e) {
      emit(
        state.copyWith(
          status: VehicleTypeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteVehicleType(
    DeleteVehicleTypeRequested event,
    Emitter<VehicleTypeState> emit,
  ) async {
    emit(state.copyWith(status: VehicleTypeStatus.loading));
    try {
      await _deleteVehicleTypeUseCase(event.vehicleTypeId);
      emit(
        state.copyWith(
          status: VehicleTypeStatus.success,
          successMessage: 'Vehicle type deleted',
        ),
      );
      add(const LoadVehicleTypes());
    } catch (e) {
      emit(
        state.copyWith(
          status: VehicleTypeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchVehicleTypes(
    SearchVehicleTypes event,
    Emitter<VehicleTypeState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadVehicleTypes());
        return;
      }
      final vehicleTypes = await _vehicleTypeRepository.searchVehicleTypes(
        event.query,
      );
      emit(
        state.copyWith(
          status: VehicleTypeStatus.loaded,
          vehicleTypes: vehicleTypes,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VehicleTypeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
