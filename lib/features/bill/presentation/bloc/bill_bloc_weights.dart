part of 'bill_bloc.dart';

extension _BillBlocWeights on BillBloc {
  double _fromKg(double valueKg, String unit) {
    return _normalizeUnit(unit) == 'ton' ? valueKg / 1000 : valueKg;
  }

  String _formatWeightText(double displayValue, String unit) {
    return _normalizeUnit(unit) == 'ton'
        ? displayValue.toStringAsFixed(3)
        : displayValue.toStringAsFixed(0);
  }

  String _normalizeUnit(String unit) {
    final value = unit.trim().toLowerCase();
    if (value == 'ton' ||
        value == 'tonne' ||
        value == 'tonnes' ||
        value == 't') {
      return 'ton';
    }
    return 'kg';
  }

  double _toKg(double value, [String? unit]) {
    final u = _normalizeUnit(unit ?? state.weightUnit);
    if (u == 'ton') {
      return value * 1000;
    }
    return value;
  }

  void _onGrossWeightChanged(
    GrossWeightChanged event,
    Emitter<BillState> emit,
  ) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }
    final displayValue = double.tryParse(event.value) ?? 0;
    if (!displayValue.isFinite || displayValue < 0) {
      emit(state.copyWith(weightValidationError: 'Gross weight is invalid'));
      return;
    }
    final kgValue = _toKg(displayValue);
    final isCleared = event.value.trim().isEmpty || displayValue == 0;
    emit(
      state.copyWith(
        grossWeightText: event.value,
        grossWeightKg: kgValue,
        clearGrossCapturedAt: isCleared,
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onGrossWeightCommitted(
    GrossWeightCommitted event,
    Emitter<BillState> emit,
  ) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }

    // In SECOND WEIGHT mode a manually entered gross weight is only meaningful
    // when gross is the capture side (reference is a tare). Compare and assign
    // automatically so a heavier entry becomes the gross weight.
    if (state.isSecondWeightMode &&
        state.previousWeighment != null &&
        state.firstWeightType == 'TARE') {
      final displayValue = double.tryParse(event.value);
      if (displayValue != null && displayValue > 0) {
        final kgValue = _toKg(displayValue);
        final refKg = state.tareWeightKg;
        final refCapturedAt = state.tareCapturedAt;
        final now = event.capturedAt ?? state.grossCapturedAt ?? DateTime.now();
        final isTon = _normalizeUnit(state.weightUnit) == 'ton';
        final enteredText = isTon
            ? (kgValue / 1000).toStringAsFixed(3)
            : kgValue.toStringAsFixed(0);
        final refText = isTon
            ? (refKg / 1000).toStringAsFixed(3)
            : refKg.toStringAsFixed(0);

        if (kgValue <= refKg) {
          emit(
            state.copyWith(
              status: BillScreenStatus.error,
              errorMessage:
                  'Current weight must be greater than the previous Gross '
                  'weight (${refKg.toStringAsFixed(0)} kg).',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            grossWeightKg: kgValue,
            grossWeightText: enteredText,
            grossCapturedAt: now,
            tareWeightKg: refKg,
            tareWeightText: refText,
            tareCapturedAt: refCapturedAt ?? now,
            firstWeightType: 'TARE',
            status: BillScreenStatus.loaded,
            clearError: true,
          ),
        );
        _recalculate(emit);
        return;
      }
    }

    final displayValue = double.tryParse(event.value);
    if (displayValue == null || displayValue <= 0) {
      if (event.value.trim().isEmpty || displayValue == 0) {
        emit(
          state.copyWith(
            grossWeightText: event.value,
            grossWeightKg: 0,
            clearGrossCapturedAt: true,
            clearError: true,
          ),
        );
        _recalculate(emit);
      }
      return;
    }
    final kgValue = _toKg(displayValue);
    final capturedAt =
        event.capturedAt ?? state.grossCapturedAt ?? DateTime.now();
    emit(
      state.copyWith(
        grossWeightText: event.value,
        grossWeightKg: kgValue,
        grossCapturedAt: capturedAt,
        firstWeightType: state.firstWeightType ?? 'GROSS',
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onTareWeightChanged(TareWeightChanged event, Emitter<BillState> emit) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }
    final displayValue = double.tryParse(event.value) ?? 0;
    if (!displayValue.isFinite || displayValue < 0) {
      emit(state.copyWith(weightValidationError: 'Tare weight is invalid'));
      return;
    }
    final kgValue = _toKg(displayValue);
    final isCleared = event.value.trim().isEmpty || displayValue == 0;
    emit(
      state.copyWith(
        tareWeightText: event.value,
        tareWeightKg: kgValue,
        clearTareCapturedAt: isCleared,
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onTareWeightCommitted(
    TareWeightCommitted event,
    Emitter<BillState> emit,
  ) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }

    if (state.isSecondWeightMode &&
        state.previousWeighment != null &&
        state.firstWeightType == 'GROSS') {
      final displayValue = double.tryParse(event.value);
      if (displayValue != null && displayValue > 0) {
        final kgValue = _toKg(displayValue);
        final refKg = state.grossWeightKg;
        final refCapturedAt = state.grossCapturedAt;
        final now = event.capturedAt ?? state.tareCapturedAt ?? DateTime.now();
        final isTon = _normalizeUnit(state.weightUnit) == 'ton';
        final enteredText = isTon
            ? (kgValue / 1000).toStringAsFixed(3)
            : kgValue.toStringAsFixed(0);
        final refText = isTon
            ? (refKg / 1000).toStringAsFixed(3)
            : refKg.toStringAsFixed(0);

        if (kgValue <= refKg) {
          emit(
            state.copyWith(
              status: BillScreenStatus.error,
              errorMessage:
                  'Current weight must be greater than the previous Gross '
                  'weight (${refKg.toStringAsFixed(0)} kg).',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            grossWeightKg: kgValue,
            grossWeightText: enteredText,
            grossCapturedAt: now,
            tareWeightKg: refKg,
            tareWeightText: refText,
            tareCapturedAt: refCapturedAt ?? now,
            firstWeightType: 'TARE',
            status: BillScreenStatus.loaded,
            clearError: true,
          ),
        );
        _recalculate(emit);
        return;
      }
    }

    final displayValue = double.tryParse(event.value);
    if (displayValue == null || displayValue <= 0) {
      if (event.value.trim().isEmpty || displayValue == 0) {
        emit(
          state.copyWith(
            tareWeightText: event.value,
            tareWeightKg: 0,
            clearTareCapturedAt: true,
            clearError: true,
          ),
        );
        _recalculate(emit);
      }
      return;
    }
    final kgValue = _toKg(displayValue);
    final capturedAt =
        event.capturedAt ?? state.tareCapturedAt ?? DateTime.now();
    emit(
      state.copyWith(
        tareWeightText: event.value,
        tareWeightKg: kgValue,
        tareCapturedAt: capturedAt,
        firstWeightType: state.firstWeightType ?? 'TARE',
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onGrossCapturedAtChanged(
    GrossCapturedAtChanged event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        grossCapturedAt: event.capturedAt,
        clearGrossCapturedAt: event.capturedAt == null,
      ),
    );
  }

  void _onTareCapturedAtChanged(
    TareCapturedAtChanged event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        tareCapturedAt: event.capturedAt,
        clearTareCapturedAt: event.capturedAt == null,
      ),
    );
  }

  void _onWeightUnitChanged(WeightUnitChanged event, Emitter<BillState> emit) {
    final oldUnit = _normalizeUnit(state.weightUnit);
    final newUnit = _normalizeUnit(event.value);
    if (oldUnit == newUnit) return;

    final newGrossKg = state.grossWeightKg;
    final newTareKg = state.tareWeightKg;
    final isNewTon = newUnit == 'ton';

    final newGrossText = newGrossKg > 0
        ? (isNewTon
              ? (newGrossKg / 1000).toStringAsFixed(3)
              : newGrossKg.toStringAsFixed(0))
        : '';

    final newTareText = newTareKg > 0
        ? (isNewTon
              ? (newTareKg / 1000).toStringAsFixed(3)
              : newTareKg.toStringAsFixed(0))
        : '';

    emit(
      state.copyWith(
        weightUnit: newUnit,
        grossWeightText: newGrossText,
        tareWeightText: newTareText,
      ),
    );
    _recalculate(emit);
  }

  void _recalculate(Emitter<BillState> emit) {
    final gw = state.grossWeightKg;
    final tw = state.tareWeightKg;

    double netWeightKg = 0;
    String? weightError;

    if (gw.isFinite && tw.isFinite && gw > 0 && tw > 0) {
      if (tw >= gw) {
        weightError = 'Gross weight must be greater than tare weight.';
        netWeightKg = 0;
      } else {
        netWeightKg = gw - tw;
      }
    }

    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    if (weightError != null) {
      updatedErrors['weight'] = weightError;
    } else if (gw > 0 || tw > 0) {
      updatedErrors.remove('weight');
    }

    emit(
      state.copyWith(
        netWeightKg: netWeightKg,
        weightValidationError: weightError,
        clearWeightError: weightError == null,
        fieldErrors: updatedErrors,
      ),
    );
  }

  void _onCaptureLiveWeight(CaptureLiveWeight event, Emitter<BillState> emit) {
    // In SECOND WEIGHT mode the previous weighment decides which field is
    // locked and which one is captured now. Capturing before the lookup
    // answered would put the live weight into an ambiguous field, so it is
    // refused until a previous bill is matched.
    if (state.isSecondWeightMode && state.previousWeighment == null) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage:
              'Enter the truck number to retrieve its previous weighment '
              'before capturing weight.',
        ),
      );
      return;
    }
    final rawLiveKg = state.liveScaleWeightKg;
    if (!rawLiveKg.isFinite || rawLiveKg == 0) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'No valid live scale weight is available.',
        ),
      );
      return;
    }
    final liveKg = rawLiveKg.abs();
    if (!state.isScaleStable || state.isScaleMotion || state.isScaleOverload) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: state.isScaleOverload
              ? 'Scale overload. Weight was not captured.'
              : 'Scale weight is not stable. Weight was not captured.',
        ),
      );
      return;
    }
    final isTon = state.weightUnit.toLowerCase() == 'ton';
    final weightStr = isTon
        ? (liveKg / 1000).toStringAsFixed(3)
        : liveKg.toStringAsFixed(0);
    final now = DateTime.now();

    // In SECOND WEIGHT mode the reference weight is already on the form; the
    // newly captured weight is compared with it and the two are assigned to
    // GROSS/TARE automatically (higher = gross, lower = tare), regardless of
    // which side the truck arrived on first.
    if (state.isSecondWeightMode && state.previousWeighment != null) {
      final refIsTare = state.firstWeightType == 'TARE';
      final refKg = refIsTare ? state.tareWeightKg : state.grossWeightKg;
      final refCapturedAt = refIsTare
          ? state.tareCapturedAt
          : state.grossCapturedAt;

      final refText = isTon
          ? (refKg / 1000).toStringAsFixed(3)
          : refKg.toStringAsFixed(0);

      if (liveKg <= refKg) {
        emit(
          state.copyWith(
            status: BillScreenStatus.error,
            errorMessage:
                'Current weight must be greater than the previous Gross '
                'weight (${refKg.toStringAsFixed(0)} kg).',
          ),
        );
        return;
      }

      // The captured weight is the new gross; the reference becomes the tare.
      emit(
        state.copyWith(
          grossWeightKg: liveKg,
          grossWeightText: weightStr,
          grossCapturedAt: now,
          tareWeightKg: refKg,
          tareWeightText: refText,
          tareCapturedAt: refCapturedAt ?? now,
          firstWeightType: 'TARE',
          status: BillScreenStatus.loaded,
          clearError: true,
        ),
      );
      _recalculate(emit);
      return;
    }

    if (event.type.toLowerCase() == 'gross') {
      emit(
        state.copyWith(
          grossWeightKg: liveKg,
          grossWeightText: weightStr,
          grossCapturedAt: now,
          firstWeightType: state.firstWeightType ?? 'GROSS',
          status: BillScreenStatus.loaded,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          tareWeightKg: liveKg,
          tareWeightText: weightStr,
          tareCapturedAt: now,
          firstWeightType: state.firstWeightType ?? 'TARE',
          status: BillScreenStatus.loaded,
          clearError: true,
        ),
      );
    }
    _recalculate(emit);
  }

  void _onLiveScaleWeightUpdated(
    LiveScaleWeightUpdated event,
    Emitter<BillState> emit,
  ) {
    if (!event.weightKg.isFinite) return;
    emit(
      state.copyWith(
        liveScaleWeightKg: event.weightKg,
        isScaleStable: event.isStable ?? state.isScaleStable,
        isScaleMotion: event.isMotion ?? state.isScaleMotion,
        isScaleOverload: event.isOverload ?? state.isScaleOverload,
      ),
    );
  }

  void _onWeightTypeSelected(
    WeightTypeSelected event,
    Emitter<BillState> emit,
  ) {
    emit(state.copyWith(selectedWeightType: event.type));
  }

  /// Validates all fields in a defined order before saving.
  ///
  /// Returns a map of field errors (field key -> error message).
}
