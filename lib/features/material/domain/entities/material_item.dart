import 'package:equatable/equatable.dart';

class MaterialItem extends Equatable {
  final int id;
  final String code;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaterialItem({
    required this.id,
    required this.code,
    required this.name,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, code, name, isActive];
}
