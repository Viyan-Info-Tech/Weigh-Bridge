part of 'bill_bloc.dart';

extension _BillBlocForm on BillBloc {
  void _onMobileNumberChanged(
    MobileNumberChanged event,
    Emitter<BillState> emit,
  ) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    final trimmed = event.value.trim();
    if (trimmed.isEmpty || RegExp(r'^\d+$').hasMatch(trimmed)) {
      updatedErrors.remove('mobile');
    }
    emit(
      state.copyWith(
        mobileNumber: event.value,
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
  }

  void _onRemarksChanged(RemarksChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(remarksText: event.value));
  }

  void _onMaterialChanged(MaterialChanged event, Emitter<BillState> emit) {
    emit(
      state.copyWith(
        materialText: event.value,
        selectedMaterialId: event.materialId,
        clearSelectedMaterialId: event.materialId == null,
      ),
    );
  }

  void _onChargesChanged(ChargesChanged event, Emitter<BillState> emit) {
    // While typing, only clear a stale error once the text parses again; the
    // authoritative validation still runs on save in [_validateAll].
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    if (event.value.trim().isEmpty || parseChargesInput(event.value) != null) {
      updatedErrors.remove('charges');
    }
    emit(
      state.copyWith(
        chargesText: event.value,
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
  }

  Future<void> _onClearBillRequested(
    ClearBillRequested event,
    Emitter<BillState> emit,
  ) async {
    final billNumber = await _generateBillNumberUseCase();
    if (emit.isDone) return;
    String unit = 'kg';
    if (_settingsRepository != null) {
      final settings = await _settingsRepository.getSettings();
      unit = _normalizeUnit(settings.weightUnit);
    }
    _resetForm(emit, nextBillNumber: billNumber, weightUnit: unit);
  }

  void _resetForm(
    Emitter<BillState> emit, {
    required String nextBillNumber,
    String? weightUnit,
  }) {
    // A reset always returns to the default normal-weighment form. Any
    // in-flight previous-weight lookup is invalidated so its late result can
    // never repopulate the freshly cleared form.
    _previousWeightLookupSeq++;
    emit(
      state.copyWith(
        vehicleNumber: '',
        clearFirstWeightType: true,
        grossWeightText: '',
        tareWeightText: '',
        remarksText: '',
        materialText: '',
        clearSelectedMaterialId: true,
        chargesText: '',
        mobileNumber: '',
        grossWeightKg: 0,
        tareWeightKg: 0,
        netWeightKg: 0,
        currentBillNumber: nextBillNumber,
        formResetRevision: state.formResetRevision + 1,
        clearError: true,
        clearWeightError: true,
        clearGrossCapturedAt: true,
        clearTareCapturedAt: true,
        clearFieldErrors: true,
        weightUnit: weightUnit ?? state.weightUnit,
        // SECOND WEIGHT mode does not survive a reset: the next truck starts
        // a fresh normal weighment. The capture target returns to the
        // default only when the reset actually leaves the mode, so a normal
        // save keeps the operator's GROSS/TARE selection as before.
        isSecondWeightMode: false,
        isFetchingPreviousWeight: false,
        clearPreviousWeighment: true,
        clearPreviousWeightMessage: true,
        selectedWeightType: state.isSecondWeightMode
            ? 'Gross'
            : state.selectedWeightType,
      ),
    );
  }
}
