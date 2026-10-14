import 'package:equatable/equatable.dart';

/// A single per-vehicle tare weight in the registry managed from the
/// Auto Tare popup.
///
/// Unlike the day's common auto tare, rows here never create bills: adding
/// one only records the tare so the operator can look it up later.
class VehicleTareRecord extends Equatable {
  const VehicleTareRecord({
    this.id,
    required this.vehicleNumber,
    required this.tareKg,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  /// Normalized upper-case vehicle number; unique per row.
  final String vehicleNumber;
  final double tareKg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, vehicleNumber, tareKg, createdAt, updatedAt];
}
