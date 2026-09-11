import 'package:equatable/equatable.dart';

class MaterialItem extends Equatable {
  final int id;
  final String name;
  final String? category;
  final String unit;
  final double defaultRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaterialItem({
    required this.id,
    required this.name,
    this.category,
    this.unit = 'ton',
    this.defaultRate = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, category, unit, defaultRate, isActive];
}
