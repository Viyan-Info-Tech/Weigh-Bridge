part of 'bill_bloc.dart';

extension _BillBlocVehicle on BillBloc {
  void _onVehicleNumberChanged(
    VehicleNumberChanged event,
    Emitter<BillState> emit,
  ) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    final trimmed = event.vehicleNumber.trim();
    if (trimmed.isNotEmpty) {
      updatedErrors.remove('vehicleNumber');
    }
    final normalized = event.vehicleNumber.trim().toUpperCase();
    final vehicleChanged = normalized != state.vehicleNumber;

    var updated = state.copyWith(
      vehicleNumber: normalized,
      fieldErrors: updatedErrors,
      clearError: true,
    );

    // A different vehicle makes any previously matched bill and its
    // populated weight stale; drop the match, the operator-facing note and
    // the weight that came from it, so they can never be saved against the
    // new number while the fresh lookup runs.
    if (vehicleChanged) {
      updated = _clearPreviousWeightData(updated);
      if (state.isSecondWeightMode) {
        updated = updated.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeightMessage: true,
        );
      }
    }

    emit(updated);

    // Typing over the number in SECOND WEIGHT mode must re-run the search so
    // the correct record is retrieved for the newly entered vehicle.
    if (vehicleChanged && state.isSecondWeightMode) {
      add(const FetchPreviousWeightForVehicle());
    }
  }

  /// Drops the matched previous bill and the weight that was populated
  /// from it, leaving the operator's own captured weight untouched.
  BillState _clearPreviousWeightData(BillState state) {
    final previous = state.previousWeighment;
    var updated = state.copyWith(
      clearPreviousWeighment: true,
      clearPreviousWeightMessage: true,
      isFetchingPreviousWeight: false,
    );
    if (previous == null) return updated;

    // The populated field is the one holding the previous bill's weight
    // type; the opposite field is where the operator captures the current
    // weight, and it must survive untouched.
    final previousIsTare = previous.referenceWeightType == 'TARE';
    updated = previousIsTare
        ? updated.copyWith(
            tareWeightText: '',
            tareWeightKg: 0,
            clearTareCapturedAt: true,
            clearFirstWeightType: true,
          )
        : updated.copyWith(
            grossWeightText: '',
            grossWeightKg: 0,
            clearGrossCapturedAt: true,
            clearFirstWeightType: true,
          );
    return updated.copyWith(netWeightKg: 0);
  }

  /// Toggles the SECOND WEIGHT workflow.
  ///
  /// Both directions drop every weight and second-weight artefact (matched
  /// bill, populated weight, messages), so a mode change can never carry
  /// stale state into the restored form. The vehicle number, material and
  /// charges the operator typed are kept: they are not second-weight state.
  void _onSecondWeightModeChanged(
    SecondWeightModeChanged event,
    Emitter<BillState> emit,
  ) {
    if (event.enabled == state.isSecondWeightMode) return;

    emit(
      _clearWeightsAndSecondWeightArtifacts(
        state.copyWith(
          isSecondWeightMode: event.enabled,
          // Leaving the mode restores the default GROSS capture target so
          // F1 never fires into a field the previous mode dictated.
          selectedWeightType: event.enabled
              ? state.selectedWeightType
              : 'Gross',
        ),
      ),
    );

    if (event.enabled && state.vehicleNumber.trim().isNotEmpty) {
      add(const FetchPreviousWeightForVehicle());
    }
  }

  /// Clears both weight fields, their capture timestamps and every
  /// second-weight artefact, while leaving the rest of the form intact.
  BillState _clearWeightsAndSecondWeightArtifacts(BillState state) {
    return state.copyWith(
      grossWeightText: '',
      grossWeightKg: 0,
      tareWeightText: '',
      tareWeightKg: 0,
      netWeightKg: 0,
      clearGrossCapturedAt: true,
      clearTareCapturedAt: true,
      clearFirstWeightType: true,
      clearWeightError: true,
      clearPreviousWeighment: true,
      clearPreviousWeightMessage: true,
      isFetchingPreviousWeight: false,
    );
  }

  /// Looks up the previous single-weight bill for the entered vehicle.
  Future<void> _onFetchPreviousWeightForVehicle(
    FetchPreviousWeightForVehicle event,
    Emitter<BillState> emit,
  ) async {
    if (!state.isSecondWeightMode) return;

    final vehicle = state.vehicleNumber.trim().toUpperCase();
    final lookupId = ++_previousWeightLookupSeq;

    if (vehicle.isEmpty) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          clearPreviousWeightMessage: true,
        ),
      );
      return;
    }

    final useCase = _previousWeighmentUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'Previous weighments are unavailable. Return to normal mode '
              'and weigh this truck from scratch.',
        ),
      );
      return;
    }

    emit(state.copyWith(isFetchingPreviousWeight: true));

    Weighment? previous;
    try {
      previous = await useCase(vehicle);
    } catch (e) {
      // A failed lookup surfaces as a message, never as an exception that
      // would leave the form stuck in the fetching state.
      if (lookupId != _previousWeightLookupSeq || emit.isDone) return;
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'Could not search previous weighments: $e. '
              'Return to normal mode or try again.',
        ),
      );
      return;
    }

    // A newer lookup owns the form now; this result is stale and dropped.
    if (lookupId != _previousWeightLookupSeq || emit.isDone) return;

    if (previous == null) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'No previous weighment found for $vehicle. '
              'Check the number or return to normal mode.',
        ),
      );
      return;
    }

    // The previous bill must carry a usable reference weight; anything else
    // would make the next weighing's net weight wrong. The reference is the
    // gross weight for a completed bill, or the single captured weight for a
    // first-pass bill.
    final previousWeightKg = previous.referenceWeightKg;
    if (previousWeightKg == null ||
        !previousWeightKg.isFinite ||
        previousWeightKg <= 0) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'The previous weighment ${previous.billNumber} for $vehicle '
              'has invalid weight data and cannot be used. '
              'Return to normal mode and weigh this truck from scratch.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isFetchingPreviousWeight: false,
        previousWeighment: previous,
        clearPreviousWeightMessage: true,
        // The previous Gross weight becomes the Tare reference for this
        // Do not assign the previous weight to Gross or Tare yet. The pairing
        // decision is made only when F1 captures the current indicator weight.
        firstWeightType: null,
        selectedWeightType: 'Gross',
        grossWeightText: '',
        grossWeightKg: 0,
        clearGrossCapturedAt: true,
        grossCapturedAt: null,
        tareWeightText: '',
        tareWeightKg: 0,
        tareCapturedAt: null,
      ),
    );
    _recalculate(emit);
  }
}
