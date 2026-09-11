import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/load_materials.dart';
import '../../domain/usecases/create_material.dart';
import '../../domain/repositories/material_item_repository.dart';
import 'material_event.dart';
import 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final LoadMaterialsUseCase _loadMaterialsUseCase;
  final CreateMaterialUseCase _createMaterialUseCase;
  final MaterialItemRepository _materialRepository;

  MaterialBloc({
    required LoadMaterialsUseCase loadMaterialsUseCase,
    required CreateMaterialUseCase createMaterialUseCase,
    required MaterialItemRepository materialRepository,
  })  : _loadMaterialsUseCase = loadMaterialsUseCase,
        _createMaterialUseCase = createMaterialUseCase,
        _materialRepository = materialRepository,
        super(const MaterialState()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<LoadMaterialById>(_onLoadMaterialById);
    on<CreateMaterialRequested>(_onCreateMaterial);
    on<UpdateMaterialRequested>(_onUpdateMaterial);
    on<DeactivateMaterialRequested>(_onDeactivateMaterial);
    on<SearchMaterials>(_onSearchMaterials);
    on<FilterMaterialsByStatus>(_onFilterByStatus);
  }

  Future<void> _onLoadMaterials(LoadMaterials event, Emitter<MaterialState> emit) async {
    emit(state.copyWith(status: AppMaterialStatus.loading));
    try {
      final materials = await _loadMaterialsUseCase(
        isActive: event.filterActive,
        category: event.filterCategory,
      );
      emit(state.copyWith(status: AppMaterialStatus.loaded, materials: materials));
    } catch (e) {
      emit(state.copyWith(status: AppMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMaterialById(LoadMaterialById event, Emitter<MaterialState> emit) async {
    emit(state.copyWith(status: AppMaterialStatus.loading));
    try {
      final material = await _materialRepository.getMaterialById(event.materialId);
      emit(state.copyWith(status: AppMaterialStatus.loaded, selectedMaterial: material));
    } catch (e) {
      emit(state.copyWith(status: AppMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateMaterial(CreateMaterialRequested event, Emitter<MaterialState> emit) async {
    emit(state.copyWith(status: AppMaterialStatus.loading));
    try {
      await _createMaterialUseCase(
        name: event.name,
        category: event.category,
        unit: event.unit,
        defaultRate: event.defaultRate,
      );
      emit(state.copyWith(status: AppMaterialStatus.success, successMessage: 'Material created successfully'));
      add(const LoadMaterials());
    } catch (e) {
      emit(state.copyWith(status: AppMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateMaterial(UpdateMaterialRequested event, Emitter<MaterialState> emit) async {
    emit(state.copyWith(status: AppMaterialStatus.loading));
    try {
      await _materialRepository.updateMaterial(
        id: event.id,
        name: event.name,
        category: event.category,
        unit: event.unit,
        defaultRate: event.defaultRate,
      );
      emit(state.copyWith(status: AppMaterialStatus.success, successMessage: 'Material updated successfully'));
      add(const LoadMaterials());
    } catch (e) {
      emit(state.copyWith(status: AppMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeactivateMaterial(DeactivateMaterialRequested event, Emitter<MaterialState> emit) async {
    emit(state.copyWith(status: AppMaterialStatus.loading));
    try {
      await _materialRepository.deactivateMaterial(event.materialId);
      emit(state.copyWith(status: AppMaterialStatus.success, successMessage: 'Material deactivated'));
      add(const LoadMaterials());
    } catch (e) {
      emit(state.copyWith(status: AppMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchMaterials(SearchMaterials event, Emitter<MaterialState> emit) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadMaterials());
        return;
      }
      final materials = await _materialRepository.searchMaterials(event.query);
      emit(state.copyWith(status: AppMaterialStatus.loaded, materials: materials, searchQuery: event.query));
    } catch (e) {
      emit(state.copyWith(status: AppMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterByStatus(FilterMaterialsByStatus event, Emitter<MaterialState> emit) async {
    add(LoadMaterials(filterActive: event.isActive));
  }
}
