import 'package:equatable/equatable.dart';

class Weighment extends Equatable {
  final int id;
  final String billNumber;
  final String vehicleNumber;
  final double firstWeightKg;
  final String firstWeightType;
  final double? secondWeightKg;
  final String? secondWeightType;
  final double? explicitNetWeightKg;
  final DateTime? explicitGrossCapturedAt;
  final DateTime? explicitTareCapturedAt;
  final String? material;
  final String? description;
  final String? remarks;
  final String? mobileNumber;
  final String weightUnit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Weighment({
    required this.id,
    required this.billNumber,
    required this.vehicleNumber,
    double? firstWeightKg,
    this.firstWeightType = 'GROSS',
    this.secondWeightKg,
    this.secondWeightType,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    DateTime? grossCapturedAt,
    DateTime? tareCapturedAt,
    this.material,
    this.description,
    this.remarks,
    this.mobileNumber,
    this.weightUnit = 'ton',
    required this.createdAt,
    required this.updatedAt,
  }) : firstWeightKg =
           firstWeightKg ??
           ((firstWeightType == 'TARE' || firstWeightType == 'tare')
               ? (tareWeightKg ?? 0)
               : (grossWeightKg ?? 0)),
       explicitNetWeightKg = netWeightKg,
       explicitGrossCapturedAt = grossCapturedAt,
       explicitTareCapturedAt = tareCapturedAt;

  bool get isCompleted => isCompletedForWeights(grossWeightKg, tareWeightKg);

  /// A saved weighment is completed once at least one valid weight exists.
  static bool isCompletedForWeights(
    double? grossWeightKg,
    double? tareWeightKg,
  ) =>
      (grossWeightKg != null && grossWeightKg > 0) ||
      (tareWeightKg != null && tareWeightKg > 0);

  /// Business Logic for Gross Weight:
  /// If firstWeightType == GROSS -> firstWeight (if > 0)
  /// If firstWeightType == TARE -> secondWeight (if available > 0, else null)
  double? get grossWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'GROSS') {
      return firstWeightKg > 0 ? firstWeightKg : null;
    } else if (type == 'TARE') {
      return (secondWeightKg != null && secondWeightKg! > 0)
          ? secondWeightKg
          : null;
    }
    return firstWeightKg > 0 ? firstWeightKg : null;
  }

  /// Business Logic for Tare Weight:
  /// If firstWeightType == TARE -> firstWeight (if > 0)
  /// If firstWeightType == GROSS -> secondWeight (if available > 0, else null)
  double? get tareWeightKg {
    final type = firstWeightType.toUpperCase();
    if (type == 'TARE') {
      return firstWeightKg > 0 ? firstWeightKg : null;
    } else if (type == 'GROSS') {
      return (secondWeightKg != null && secondWeightKg! > 0)
          ? secondWeightKg
          : null;
    }
    return (secondWeightKg != null && secondWeightKg! > 0)
        ? secondWeightKg
        : null;
  }

  /// Net Weight:
  /// (gross - tare).abs() when both exist
  double? get netWeightKg {
    if (explicitNetWeightKg != null && explicitNetWeightKg! > 0) {
      return explicitNetWeightKg;
    }
    final g = grossWeightKg;
    final t = tareWeightKg;
    if (g != null && t != null && g > 0 && t > 0) {
      return (g - t).abs();
    }
    return null;
  }

  DateTime? get grossCapturedAt {
    if (explicitGrossCapturedAt != null) return explicitGrossCapturedAt;
    final type = firstWeightType.toUpperCase();
    if (type == 'GROSS') {
      return firstWeightKg > 0 ? createdAt : null;
    } else if (type == 'TARE') {
      return (secondWeightKg != null && secondWeightKg! > 0) ? updatedAt : null;
    }
    return firstWeightKg > 0 ? createdAt : null;
  }

  DateTime? get tareCapturedAt {
    if (explicitTareCapturedAt != null) return explicitTareCapturedAt;
    final type = firstWeightType.toUpperCase();
    if (type == 'TARE') {
      return firstWeightKg > 0 ? createdAt : null;
    } else if (type == 'GROSS') {
      return (secondWeightKg != null && secondWeightKg! > 0) ? updatedAt : null;
    }
    return (secondWeightKg != null && secondWeightKg! > 0) ? updatedAt : null;
  }

  Weighment copyWith({
    int? id,
    String? billNumber,
    String? vehicleNumber,
    double? firstWeightKg,
    String? firstWeightType,
    double? secondWeightKg,
    String? secondWeightType,
    double? netWeightKg,
    DateTime? grossCapturedAt,
    DateTime? tareCapturedAt,
    String? material,
    String? description,
    String? remarks,
    String? mobileNumber,
    String? weightUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Weighment(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      firstWeightKg: firstWeightKg ?? this.firstWeightKg,
      firstWeightType: firstWeightType ?? this.firstWeightType,
      secondWeightKg: secondWeightKg ?? this.secondWeightKg,
      secondWeightType: secondWeightType ?? this.secondWeightType,
      netWeightKg: netWeightKg ?? this.explicitNetWeightKg,
      grossCapturedAt: grossCapturedAt ?? this.grossCapturedAt,
      tareCapturedAt: tareCapturedAt ?? this.tareCapturedAt,
      material: material ?? this.material,
      description: description ?? this.description,
      remarks: remarks ?? this.remarks,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      weightUnit: weightUnit ?? this.weightUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    billNumber,
    vehicleNumber,
    firstWeightKg,
    firstWeightType,
    secondWeightKg,
    secondWeightType,
    explicitNetWeightKg,
    explicitGrossCapturedAt,
    explicitTareCapturedAt,
    material,
    description,
    remarks,
    mobileNumber,
    weightUnit,
    createdAt,
    updatedAt,
  ];
}
