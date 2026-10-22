import 'package:equatable/equatable.dart';

/// A material master record: a material name paired with the vehicle type it
/// applies to (Empty or Load).
class MaterialItem extends Equatable {
  final int? id;
  final String name;
  final String vehicleType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MaterialItem({
    this.id,
    required this.name,
    required this.vehicleType,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// The name shown on bills, reports and re-prints: `Auto - Empty`.
  String get displayValue => '$name - $vehicleType';

  MaterialItem copyWith({
    int? id,
    String? name,
    String? vehicleType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleType: vehicleType ?? this.vehicleType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        vehicleType,
        isActive,
        createdAt,
        updatedAt,
      ];
}
