import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/material_repository.dart';
import '../../domain/usecases/create_material.dart';
import '../../domain/usecases/delete_material.dart';
import '../../domain/usecases/load_materials.dart';
import '../../domain/usecases/update_material.dart';
import 'material_event.dart';
import 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final LoadMaterials loadMaterials;
  final CreateMaterial createMaterial;
  final UpdateMaterial updateMaterial;
  final DeleteMaterial deleteMaterial;

  MaterialBloc({
    required this.loadMaterials,
    required this.createMaterial,
    required this.updateMaterial,
    required this.deleteMaterial,
  }) : super(const MaterialState()) {
    on<LoadMaterialsEvent>(_onLoadMaterials);
    on<MaterialSavedEvent>(_onSaveMaterial);
    on<MaterialDeletedEvent>(_onDeleteMaterial);
  }

  Future<void> _onLoadMaterials(
    LoadMaterialsEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final materials = await loadMaterials();
      emit(
        state.copyWith(
          materials: materials,
          isLoading: false,
          clearSuccessMessage: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSaveMaterial(
    MaterialSavedEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final material = event.material;
      if (material.id == null) {
        await createMaterial(material.name, material.vehicleType);
      } else {
        await updateMaterial(material);
      }
      final materials = await loadMaterials();
      emit(state.copyWith(
        materials: materials,
        isLoading: false,
        successMessage: 'Material saved successfully',
      ));
    } on DuplicateMaterialException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } on InvalidMaterialException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteMaterial(
    MaterialDeletedEvent event,
    Emitter<MaterialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await deleteMaterial(event.id);
      final materials = await loadMaterials();
      emit(state.copyWith(
        materials: materials,
        isLoading: false,
        successMessage: 'Material deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
