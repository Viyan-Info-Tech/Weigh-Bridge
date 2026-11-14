/// Result of attempting to pair a captured weight with the previous reference.
sealed class WeightPairingResult {
  const WeightPairingResult();
}

/// The two weights were paired successfully.
class WeightPairingPaired extends WeightPairingResult {
  const WeightPairingPaired({required this.grossKg, required this.tareKg});

  final double grossKg;
  final double tareKg;

  double get netKg => grossKg - tareKg;
}

/// The capture was rejected.
class WeightPairingRejected extends WeightPairingResult {
  const WeightPairingRejected(this.message);

  final String message;
}

/// Single source of truth for the second-weight pairing rule.
///
/// Pairs the previous reference weight with the captured (current) indicator
/// weight. The higher value always becomes Gross and the lower value always
/// becomes Tare, regardless of which was captured first.
class WeightPairingService {
  const WeightPairingService();

  WeightPairingResult pair({
    required double previousKg,
    required double currentKg,
  }) {
    if (!currentKg.isFinite || currentKg <= 0) {
      return const WeightPairingRejected('Current weight is invalid.');
    }
    if (!previousKg.isFinite || previousKg <= 0) {
      return const WeightPairingRejected('Previous weight is invalid.');
    }
    final grossKg = currentKg > previousKg ? currentKg : previousKg;
    final tareKg = currentKg > previousKg ? previousKg : currentKg;
    return WeightPairingPaired(grossKg: grossKg, tareKg: tareKg);
  }
}
