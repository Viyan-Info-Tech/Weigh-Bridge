import 'package:equatable/equatable.dart';

import '../../domain/entities/material_item.dart';

abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaterialsEvent extends MaterialEvent {
  const LoadMaterialsEvent();
}

class MaterialSavedEvent extends MaterialEvent {
  final MaterialItem material;

  const MaterialSavedEvent(this.material);

  @override
  List<Object?> get props => [material];
}

class MaterialDeletedEvent extends MaterialEvent {
  final int id;

  const MaterialDeletedEvent(this.id);

  @override
  List<Object?> get props => [id];
}
