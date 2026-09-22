import 'package:equatable/equatable.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaterials extends MaterialEvent {
  final String? searchQuery;
  final bool? filterActive;

  const LoadMaterials({this.searchQuery, this.filterActive});

  @override
  List<Object?> get props => [searchQuery, filterActive];
}

class CreateMaterialRequested extends MaterialEvent {
  final String code;
  final String name;

  const CreateMaterialRequested({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}

class UpdateMaterialRequested extends MaterialEvent {
  final int id;
  final String code;
  final String name;

  const UpdateMaterialRequested({
    required this.id,
    required this.code,
    required this.name,
  });

  @override
  List<Object?> get props => [id, code, name];
}

class DeactivateMaterialRequested extends MaterialEvent {
  final int materialId;

  const DeactivateMaterialRequested(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

class ActivateMaterialRequested extends MaterialEvent {
  final int materialId;

  const ActivateMaterialRequested(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

class DeleteMaterialRequested extends MaterialEvent {
  final int materialId;

  const DeleteMaterialRequested(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

class SearchMaterials extends MaterialEvent {
  final String query;

  const SearchMaterials(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterMaterialsByStatus extends MaterialEvent {
  final bool? isActive;

  const FilterMaterialsByStatus(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class LoadMaterialById extends MaterialEvent {
  final int materialId;

  const LoadMaterialById(this.materialId);

  @override
  List<Object?> get props => [materialId];
}
