import '../entities/weighment.dart';

/// Weight values used for receipt display.
///
/// A value of `null` means "not captured" and must be rendered as `--`
/// by both the on-screen preview and the printed ticket. It must never
/// be rendered as `0` and must never be used to fabricate a net weight.
class ResolvedReceiptWeights {
  final double? grossKg;
  final double? tareKg;
  final double? netKg;

  const ResolvedReceiptWeights({this.grossKg, this.tareKg, this.netKg});
}

/// Resolves the display weights of a [Weighment] for receipt purposes.
///
/// This is the single source of truth shared by the receipt preview
/// widget and the ticket PDF generator so the printed ticket always
/// matches the preview exactly.
class ReceiptWeightResolver {
  const ReceiptWeightResolver();

  ResolvedReceiptWeights resolve(Weighment bill) {
    final double? resolvedGrossKg =
        bill.grossWeightKg ??
        (bill.firstWeightType.toUpperCase() == 'GROSS'
            ? (bill.firstWeightKg > 0 ? bill.firstWeightKg : null)
            : (bill.secondWeightKg != null && bill.secondWeightKg! > 0
                  ? bill.secondWeightKg
                  : null)) ??
        ((bill.tareWeightKg != null &&
                bill.netWeightKg != null &&
                bill.tareWeightKg! > 0 &&
                bill.netWeightKg! > 0)
            ? (bill.tareWeightKg! + bill.netWeightKg!)
            : null);

    final double? resolvedTareKg =
        bill.tareWeightKg ??
        (bill.firstWeightType.toUpperCase() == 'TARE'
            ? (bill.firstWeightKg > 0 ? bill.firstWeightKg : null)
            : (bill.secondWeightKg != null && bill.secondWeightKg! > 0
                  ? bill.secondWeightKg
                  : null)) ??
        ((resolvedGrossKg != null &&
                bill.netWeightKg != null &&
                resolvedGrossKg > 0 &&
                bill.netWeightKg! > 0)
            ? (resolvedGrossKg - bill.netWeightKg!)
            : null);

    final double? resolvedNetKg =
        bill.netWeightKg ??
        ((resolvedGrossKg != null &&
                resolvedTareKg != null &&
                resolvedGrossKg > 0 &&
                resolvedTareKg > 0)
            ? (resolvedGrossKg - resolvedTareKg).abs()
            : null);

    return ResolvedReceiptWeights(
      grossKg: resolvedGrossKg,
      tareKg: resolvedTareKg,
      netKg: resolvedNetKg,
    );
  }
}
