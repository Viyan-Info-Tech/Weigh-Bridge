part of 'bill_bloc.dart';

extension _BillBlocValidation on BillBloc {
  Map<String, String> _validateAll() {
    final errors = <String, String>{};

    // ── 1. Truck / Vehicle Number ──────────────────────────────
    final rawVehicle = state.vehicleNumber.trim();
    if (rawVehicle.isEmpty) {
      errors['vehicleNumber'] = 'Truck number is required.';
    }

    // ── 2. Weight presence ────────────────────────────────────
    final hasGross = state.grossWeightKg.isFinite && state.grossWeightKg > 0;
    final hasTare = state.tareWeightKg.isFinite && state.tareWeightKg > 0;
    if (!hasGross && !hasTare) {
      errors['weight'] = 'Enter or capture Gross or Tare weight.';
    } else if (hasGross &&
        (!state.grossWeightKg.isFinite || state.grossWeightKg < 0)) {
      errors['weight'] = 'Gross weight is invalid';
    } else if (hasTare &&
        (!state.tareWeightKg.isFinite || state.tareWeightKg < 0)) {
      errors['weight'] = 'Tare weight is invalid';
    } else if (hasGross &&
        hasTare &&
        state.tareWeightKg >= state.grossWeightKg) {
      errors['weight'] = 'Gross weight must be greater than tare weight.';
    } else if (state.weightValidationError != null) {
      errors['weight'] = state.weightValidationError!;
    } else if (hasGross && state.grossCapturedAt == null) {
      errors['weight'] =
          'Gross weight timestamp is missing. Re-enter the gross weight.';
    } else if (hasTare && state.tareCapturedAt == null) {
      errors['weight'] =
          'Tare weight timestamp is missing. Re-enter the tare weight.';
    }

    // ── 2b. Second-weight workflow ───────────────────────────
    // A second weighing pairs a retrieved previous weight with the weight
    // captured now, so both must be present before the bill can be saved.
    if (state.isSecondWeightMode) {
      if (state.previousWeighment == null) {
        errors['vehicleNumber'] =
            state.previousWeightMessage ?? 'Retrieve the previous weighment.';
      } else if (!hasGross || !hasTare) {
        errors['weight'] =
            'Capture the current weight to complete the second weighing.';
      } else if (state.weightValidationError != null) {
        errors['weight'] = state.weightValidationError!;
      }
    }

    // ── 3. Mobile number (optional) ───────────────────────────
    final mobile = state.mobileNumber.trim();
    if (mobile.isNotEmpty) {
      if (!RegExp(r'^\d+$').hasMatch(mobile)) {
        errors['mobile'] = 'Mobile number can contain digits only.';
      }
    }

    // ── 4. Charges (optional) ─────────────────────────────────
    // Empty is valid (no charge); anything typed must be a non-negative
    // amount with at most two decimals.
    final chargesText = state.chargesText.trim();
    if (chargesText.isNotEmpty && parseChargesInput(chargesText) == null) {
      errors['charges'] = 'Enter a valid amount (digits, up to two decimals).';
    }

    return errors;
  }
}
