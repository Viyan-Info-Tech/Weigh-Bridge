import 'package:equatable/equatable.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaterials extends MaterialEvent {
  final String? searchQuery;
  final bool? filterActive;
  final String? filterCategory;

  const LoadMaterials({this.searchQuery, this.filterActive, this.filterCategory});

  @override
  List<Object?> get props => [searchQuery, filterActive, filterCategory];
}

class CreateMaterialRequested extends MaterialEvent {
  final String name;
  final String? category;
  final String unit;
  final double defaultRate;

  const CreateMaterialRequested({
    required this.name,
    this.category,
    this.unit = 'ton',
    this.defaultRate = 0,
  });

  @override
  List<Object?> get props => [name, category, unit, defaultRate];
}

class UpdateMaterialRequested extends MaterialEvent {
  final int id;
  final String name;
  final String? category;
  final String unit;
  final double defaultRate;

  const UpdateMaterialRequested({
    required this.id,
    required this.name,
    this.category,
    this.unit = 'ton',
    this.defaultRate = 0,
  });

  @override
  List<Object?> get props => [id, name, category, unit, defaultRate];
}

class DeactivateMaterialRequested extends MaterialEvent {
  final int materialId;

  const DeactivateMaterialRequested(this.materialId);

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
