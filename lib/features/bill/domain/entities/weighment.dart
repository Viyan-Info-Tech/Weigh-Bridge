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

  /// Material name + vehicle type snapshot stored with the weighment
  /// (e.g. `Auto - Empty`), or null when the operator left it empty.
  final String? material;

  /// Reference to the material master row selected on the form, or null for
  /// legacy rows / tare-only weighments. The [material] text stays the
  /// authoritative display value so old bills never change.
  final int? materialId;

  /// Manually entered charges in rupees; null when the operator left it blank
  /// (including all legacy rows created before this field existed).
  final double? charges;
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
    this.material,
    this.materialId,
    this.charges,
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
       explicitNetWeightKg = netWeightKg;

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
    final type = firstWeightType.toUpperCase();
    if (type == 'GROSS') {
      return firstWeightKg > 0 ? createdAt : null;
    } else if (type == 'TARE') {
      return (secondWeightKg != null && secondWeightKg! > 0) ? updatedAt : null;
    }
    return firstWeightKg > 0 ? createdAt : null;
  }

  DateTime? get tareCapturedAt {
    final type = firstWeightType.toUpperCase();
    if (type == 'TARE') {
      return firstWeightKg > 0 ? createdAt : null;
    } else if (type == 'GROSS') {
      return (secondWeightKg != null && secondWeightKg! > 0) ? updatedAt : null;
    }
    return (secondWeightKg != null && secondWeightKg! > 0) ? updatedAt : null;
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
    material,
    materialId,
    charges,
    mobileNumber,
    weightUnit,
    createdAt,
    updatedAt,
  ];
}
