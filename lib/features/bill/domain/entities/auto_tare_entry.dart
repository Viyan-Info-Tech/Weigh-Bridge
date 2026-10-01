import 'package:equatable/equatable.dart';

/// The common/platform tare weight configured for a single calendar day.
class AutoTareEntry extends Equatable {
  const AutoTareEntry({
    required this.tareDate,
    required this.tareKg,
    this.createdAt,
    this.updatedAt,
  });

  final DateTime tareDate;
  final double tareKg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [tareDate, tareKg, createdAt, updatedAt];
}
