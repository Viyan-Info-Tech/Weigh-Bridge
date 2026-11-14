part of 'bill_bloc.dart';

extension _BillBlocSave on BillBloc {
  Future<void> _onSaveBillRequested(
    SaveBillRequested event,
    Emitter<BillState> emit,
  ) async {
    // Ignore the duplicate half of a single save request; see [_formJustSaved].
    if (state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing) {
      return;
    }
    final errors = _validateAll();
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(fieldErrors: errors, errorMessage: errors.values.first),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BillScreenStatus.saving,
        clearError: true,
        clearFieldErrors: true,
      ),
    );

    try {
      await _insertNewBill(emit);
      if (emit.isDone) return;
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(state.copyWith(status: BillScreenStatus.saved, recentBills: bills));
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Failed to save bill: $e',
        ),
      );
    }
  }

  Future<void> _onSaveAndPrintBillRequested(
    SaveAndPrintBillRequested event,
    Emitter<BillState> emit,
  ) async {
    // Ignore the duplicate half of a single Ctrl+S; see [_formJustSaved].
    if (state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing) {
      return;
    }
    final errors = _validateAll();
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(fieldErrors: errors, errorMessage: errors.values.first),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BillScreenStatus.printing,
        clearError: true,
        clearFieldErrors: true,
      ),
    );

    try {
      final savedBill = await _insertNewBill(emit);
      if (emit.isDone) return;
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.printing,
          recentBills: bills,
          printReceiptBill: savedBill,
        ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Failed to save bill: $e',
        ),
      );
    }
  }

  void _onPrintReceiptDismissed(
    PrintReceiptDismissed event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(clearPrintReceipt: true, status: BillScreenStatus.loaded),
    );
  }

  /// Persists the active form as a brand new bill.
  ///
  /// There is deliberately no update path: a saved bill is an immutable
  /// historical record and is never edited in place. Every save allocates a
  /// fresh serial number inside the database insert transaction.
  Future<Weighment> _insertNewBill(Emitter<BillState> emit) async {
    // Persist the first captured weight and leave the second absent until
    // the truck returns for its other weighing.
    final firstWeightType =
        state.firstWeightType?.toUpperCase() ??
        (state.grossWeightKg > 0 ? 'GROSS' : 'TARE');
    final firstWeightKg = firstWeightType == 'GROSS'
        ? state.grossWeightKg
        : state.tareWeightKg;
    final secondWeight = firstWeightType == 'GROSS'
        ? state.tareWeightKg
        : state.grossWeightKg;
    final secondWeightKg = secondWeight > 0 ? secondWeight : null;
    final secondWeightType = secondWeightKg == null
        ? null
        : (firstWeightType == 'GROSS' ? 'TARE' : 'GROSS');

    // The billing time of this bill is the moment it is saved. It is
    // deliberately not derived from the weight capture fields, so Recent
    // Billings always shows when each bill was actually created rather than
    // when a weight was captured.
    //
    // [updatedAt] is stamped with the same moment so a two-weight bill can
    // never end up with an `updatedAt` older than its `createdAt`.
    final createdAt = DateTime.now();
    final updatedAt = createdAt;

    final netWeight = (state.grossWeightKg > 0 && state.tareWeightKg > 0)
        ? (state.grossWeightKg - state.tareWeightKg).abs()
        : null;

    final weighment = Weighment(
      id: 0,
      // Placeholder only: the serial number is allocated by the database
      // inside the insert transaction. The value stored on the returned row is
      // authoritative and replaces this immediately below.
      billNumber: state.currentBillNumber,
      vehicleNumber: state.vehicleNumber.trim().toUpperCase(),
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      secondWeightType: secondWeightType,
      netWeightKg: netWeight,
      material: state.materialText.trim().isNotEmpty
          ? state.materialText.trim()
          : null,
      materialId: state.selectedMaterialId,
      // Manually entered charges: empty means no charge (NULL), a valid
      // amount is stored exactly as typed (never recalculated).
      charges: parseChargesInput(state.chargesText),
      // Traceable link to the single-weight bill this second weighing
      // completes. Normal weighments store NULL. The original bill itself is
      // never modified: this is a one-way reference on the new row only.
      previousWeighmentId: state.isSecondWeightMode
          ? state.previousWeighment?.id
          : null,
      remarks: state.remarksText.isNotEmpty ? state.remarksText : null,
      mobileNumber: null,
      weightUnit: state.weightUnit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    // A new bill never reuses the previewed serial number. The database
    // allocates it inside the insert transaction, which is the only place
    // that can guarantee the number is unused, and the returned value is what
    // gets displayed, printed and stored on the saved weighment.
    final result = await _saveBillUseCase.withNewBillNumber(weighment);

    final savedWeighment = Weighment(
      id: result.id,
      billNumber: result.billNumber,
      vehicleNumber: weighment.vehicleNumber,
      firstWeightKg: weighment.firstWeightKg,
      firstWeightType: weighment.firstWeightType,
      secondWeightKg: weighment.secondWeightKg,
      secondWeightType: weighment.secondWeightType,
      netWeightKg: weighment.explicitNetWeightKg,
      material: weighment.material,
      materialId: weighment.materialId,
      charges: weighment.charges,
      previousWeighmentId: weighment.previousWeighmentId,
      remarks: weighment.remarks,
      mobileNumber: weighment.mobileNumber,
      weightUnit: weighment.weightUnit,
      createdAt: weighment.createdAt,
      updatedAt: weighment.updatedAt,
    );

    final nextBillNumber = await _generateBillNumberUseCase();
    String unit = 'kg';
    if (_settingsRepository != null) {
      final settings = await _settingsRepository.getSettings();
      unit = _normalizeUnit(settings.weightUnit);
    }
    _resetForm(emit, nextBillNumber: nextBillNumber, weightUnit: unit);

    return savedWeighment;
  }
}
