part of 'bill_bloc.dart';

extension _BillBlocLoading on BillBloc {
  Future<void> _onLoadBillScreen(
    LoadBillScreen event,
    Emitter<BillState> emit,
  ) async {
    emit(state.copyWith(status: BillScreenStatus.loading, clearError: true));

    try {
      final billsDate = _dayOnly(DateTime.now());
      final recentBills = await _loadRecentBillsUseCase(date: billsDate);
      if (emit.isDone) return;
      final billNumber = await _generateBillNumberUseCase();
      if (emit.isDone) return;

      String unit = 'kg';
      if (_settingsRepository != null) {
        final settings = await _settingsRepository.getSettings();
        unit = _normalizeUnit(settings.weightUnit);
      }

      final materials = await _loadMaterialOptions();

      emit(
        state.copyWith(
          status: BillScreenStatus.loaded,
          recentBills: recentBills,
          billsDate: billsDate,
          currentBillNumber: billNumber,
          weightUnit: unit,
          materialOptions: materials,
        ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Failed to load bill screen: $e',
        ),
      );
    }
  }

  /// Refreshes the bill number, recent bills and material options without
  /// touching anything the operator has already entered on the form.
  Future<void> _onRefreshBillLookups(
    RefreshBillLookups event,
    Emitter<BillState> emit,
  ) async {
    try {
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      final materials = await _loadMaterialOptions();
      if (emit.isDone) return;
      emit(state.copyWith(recentBills: bills, materialOptions: materials));
    } catch (_) {
      // A failed refresh must not disturb the form.
      return;
    }
  }

  /// Active materials for the dropdown, or an empty list when the material
  /// feature is not wired (older tests / manual construction).
  Future<List<MaterialItem>> _loadMaterialOptions() async {
    final repository = _materialRepository;
    if (repository == null) return const [];
    try {
      return await repository.getActive();
    } catch (_) {
      // A failed material load must not block bill entry.
      return const [];
    }
  }

  Future<void> _onLoadRecentBills(
    LoadRecentBills event,
    Emitter<BillState> emit,
  ) async {
    try {
      if (event.startDate != null && event.endDate != null) {
        final bills = await _loadRecentBillsUseCase.byDateRange(
          startDate: _dayOnly(event.startDate!),
          endDate: _dayOnly(event.endDate!),
        );
        if (emit.isDone) return;
        emit(
          state.copyWith(
            recentBills: bills,
            billsStartDate: _dayOnly(event.startDate!),
            billsEndDate: _dayOnly(event.endDate!),
            clearDateRange: false,
          ),
        );
      } else {
        final billsDate = _dayOnly(event.date ?? DateTime.now());
        final bills = await _loadBillsFor(billsDate);
        if (emit.isDone) return;
        emit(
          state.copyWith(
            recentBills: bills,
            billsDate: billsDate,
            clearDateRange: true,
          ),
        );
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(errorMessage: 'Failed to load recent bills'));
    }
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<List<Weighment>> _loadBillsFor(DateTime date) {
    return _loadRecentBillsUseCase(date: _dayOnly(date));
  }
}
