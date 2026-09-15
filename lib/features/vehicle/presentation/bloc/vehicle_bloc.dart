import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/load_vehicles.dart';
import '../../domain/usecases/create_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final LoadVehiclesUseCase _loadVehiclesUseCase;
  final CreateVehicleUseCase _createVehicleUseCase;
  final DeleteVehicleUseCase _deleteVehicleUseCase;
  final VehicleRepository _vehicleRepository;

  VehicleBloc({
    required LoadVehiclesUseCase loadVehiclesUseCase,
    required CreateVehicleUseCase createVehicleUseCase,
    required DeleteVehicleUseCase deleteVehicleUseCase,
    required VehicleRepository vehicleRepository,
  }) : _loadVehiclesUseCase = loadVehiclesUseCase,
       _createVehicleUseCase = createVehicleUseCase,
       _deleteVehicleUseCase = deleteVehicleUseCase,
       _vehicleRepository = vehicleRepository,
       super(const VehicleState()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadVehicleById>(_onLoadVehicleById);
    on<CreateVehicleRequested>(_onCreateVehicle);
    on<UpdateVehicleRequested>(_onUpdateVehicle);
    on<DeactivateVehicleRequested>(_onDeactivateVehicle);
    on<DeleteVehicleRequested>(_onDeleteVehicle);
    on<SearchVehicles>(_onSearchVehicles);
    on<FilterVehiclesByStatus>(_onFilterByStatus);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      final vehicles = await _loadVehiclesUseCase(isActive: event.filterActive);
      emit(state.copyWith(status: VehicleStatus.loaded, vehicles: vehicles));
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadVehicleById(
    LoadVehicleById event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      final vehicle = await _vehicleRepository.getVehicleById(event.vehicleId);
      emit(
        state.copyWith(status: VehicleStatus.loaded, selectedVehicle: vehicle),
      );
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateVehicle(
    CreateVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      await _createVehicleUseCase(
        vehicleNumber: event.vehicleNumber,
        vehicleTypeId: event.vehicleTypeId,
        driverName: event.driverName,
        driverPhone: event.driverPhone,
      );
      emit(
        state.copyWith(
          status: VehicleStatus.success,
          successMessage: 'Vehicle created successfully',
        ),
      );
      add(const LoadVehicles());
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      await _vehicleRepository.updateVehicle(
        id: event.id,
        vehicleNumber: event.vehicleNumber,
        vehicleTypeId: event.vehicleTypeId,
        driverName: event.driverName,
        driverPhone: event.driverPhone,
      );
      emit(
        state.copyWith(
          status: VehicleStatus.success,
          successMessage: 'Vehicle updated successfully',
        ),
      );
      add(const LoadVehicles());
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeactivateVehicle(
    DeactivateVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      await _vehicleRepository.deactivateVehicle(event.vehicleId);
      emit(
        state.copyWith(
          status: VehicleStatus.success,
          successMessage: 'Vehicle deactivated',
        ),
      );
      add(const LoadVehicles());
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));
    try {
      await _deleteVehicleUseCase(event.vehicleId);
      emit(
        state.copyWith(
          status: VehicleStatus.success,
          successMessage: 'Vehicle deleted',
        ),
      );
      add(const LoadVehicles());
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSearchVehicles(
    SearchVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadVehicles());
        return;
      }
      final vehicles = await _vehicleRepository.searchVehicles(event.query);
      emit(
        state.copyWith(
          status: VehicleStatus.loaded,
          vehicles: vehicles,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: VehicleStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onFilterByStatus(
    FilterVehiclesByStatus event,
    Emitter<VehicleState> emit,
  ) async {
    add(LoadVehicles(filterActive: event.isActive));
  }
}
