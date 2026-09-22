import 'package:equatable/equatable.dart';

import '../../domain/entities/material_item.dart';

enum AppMaterialStatus { initial, loading, loaded, error, success }

class MaterialState extends Equatable {
  final AppMaterialStatus status;
  final List<MaterialItem> materials;
  final MaterialItem? selectedMaterial;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;
  final bool? filterActive;

  const MaterialState({
    this.status = AppMaterialStatus.initial,
    this.materials = const [],
    this.selectedMaterial,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
    this.filterActive,
  });

  MaterialState copyWith({
    AppMaterialStatus? status,
    List<MaterialItem>? materials,
    MaterialItem? selectedMaterial,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    bool? filterActive,
  }) {
    return MaterialState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive: filterActive ?? this.filterActive,
    );
  }

  @override
  List<Object?> get props => [
    status,
    materials,
    selectedMaterial,
    errorMessage,
    successMessage,
    searchQuery,
    filterActive,
  ];
}
