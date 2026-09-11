import 'package:equatable/equatable.dart';

class VehicleType extends Equatable {
  final int id;
  final String name;
  final double emptyPrice;
  final double loadPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleType({
    required this.id,
    required this.name,
    this.emptyPrice = 0,
    this.loadPrice = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, emptyPrice, loadPrice, isActive];
}
