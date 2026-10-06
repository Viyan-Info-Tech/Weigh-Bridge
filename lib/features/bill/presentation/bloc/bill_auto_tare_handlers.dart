import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auto_tare_repository.dart';
import '../../domain/usecases/delete_auto_tare_for_date.dart';
import '../../domain/usecases/get_auto_tare_for_date.dart';
import '../../domain/usecases/save_auto_tare_for_date.dart';
import 'bill_event.dart';
import 'bill_state.dart';

/// Auto tare event handlers for [BillBloc].
///
/// Split out of `bill_bloc.dart` so the common-tare lifecycle (load, save,
/// delete) stays readable next to the weight handling code. The mixin expects
/// the host to supply [autoTareRepository]; when it is null the build has no
/// auto tare storage and every request fails fast.
mixin BillAutoTareHandlers on Bloc<BillEvent, BillState> {
  AutoTareRepository? get autoTareRepository;

  /// Recomputes net weight and the weight validation error from the current
  /// gross/tare pair. Supplied by the host bloc.
  void recalculateWeights(Emitter<BillState> emit);

  DateTime autoTareDayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Loads the day's common tare. A day with no stored value reports "Not
  /// Set" rather than falling back to the previous day's tare.
  Future<void> handleLoadAutoTare(
    LoadAutoTare event,
    Emitter<BillState> emit,
  ) async {
    final repository = autoTareRepository;
    if (repository == null) return;

    final day = autoTareDayOnly(event.date ?? DateTime.now());
    try {
      final entry = await GetAutoTareForDate(repository)(day);
      if (emit.isDone) return;
      emit(
        entry == null
            ? state.copyWith(clearAutoTare: true, clearError: true)
            : state.copyWith(
                autoTareKg: entry.tareKg,
                autoTareDate: entry.tareDate,
                autoTareSavedAt: entry.savedAt,
                clearError: true,
              ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(errorMessage: 'Failed to load auto tare: $e'));
    }
  }

  Future<void> handleSaveAutoTare(
    SaveAutoTare event,
    Emitter<BillState> emit,
  ) async {
    final repository = autoTareRepository;
    if (repository == null) {
      event.completer?.completeError(
        Exception('Auto tare is not configured for this build.'),
      );
      return;
    }

    final day = autoTareDayOnly(event.date ?? DateTime.now());
    final saveTime = event.savedAt ?? DateTime.now();
    Object? failure;
    try {
      final entry = await SaveAutoTareForDate(repository)(
        date: day,
        tareKg: event.tareKg,
        savedAt: saveTime,
      );
      if (emit.isDone) return;
      emit(
        state.copyWith(
          autoTareKg: entry.tareKg,
          autoTareDate: entry.tareDate,
          autoTareSavedAt: entry.savedAt,
          clearError: true,
        ),
      );
    } catch (e) {
      failure = e;
      if (emit.isDone) return;
      emit(state.copyWith(errorMessage: 'Failed to save auto tare: $e'));
    } finally {
      // Always release the caller: an identical state emits nothing, so
      // waiting on the state stream would hang the dialog forever.
      final completer = event.completer;
      if (completer != null && !completer.isCompleted) {
        if (failure != null) {
          completer.completeError(failure);
        } else {
          completer.complete();
        }
      }
    }
  }

  Future<void> handleDeleteAutoTare(
    DeleteAutoTare event,
    Emitter<BillState> emit,
  ) async {
    final repository = autoTareRepository;
    if (repository == null) {
      event.completer?.completeError(
        Exception('Auto tare is not configured for this build.'),
      );
      return;
    }

    final day = autoTareDayOnly(event.date ?? DateTime.now());
    Object? failure;
    try {
      await DeleteAutoTareForDate(repository)(day);
      if (emit.isDone) return;
      emit(state.copyWith(clearAutoTare: true, clearError: true));
    } catch (e) {
      failure = e;
      if (emit.isDone) return;
      emit(state.copyWith(errorMessage: 'Failed to delete auto tare: $e'));
    } finally {
      final completer = event.completer;
      if (completer != null && !completer.isCompleted) {
        if (failure != null) {
          completer.completeError(failure);
        } else {
          completer.complete();
        }
      }
    }
  }

  /// F3 / AUTO TARE: copies the day's configured common tare into the bill
  /// currently being edited and stamps the tare with the Auto Tare's configured
  /// date and time.
  ///
  /// The configured auto tare is never modified, so bills saved earlier keep
  /// their own tare and timestamp. The capture timestamp is the exact moment
  /// the Auto Tare was saved or last updated.
  ///
  /// This is the Auto Tare's own reference time and deliberately does not
  /// affect the billing time of the bill: `Weighment.createdAt` is stamped with
  /// the moment the bill is saved, so a bill weighed against this reference
  /// still reports its real creation time.
  void handleApplyAutoTareToBill(
    ApplyAutoTareToBill event,
    Emitter<BillState> emit,
  ) {
    if (!state.hasAutoTare) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Auto Tare is not configured for today.',
        ),
      );
      return;
    }

    final tareKg = state.autoTareKg;
    final isTon = state.weightUnit.toLowerCase() == 'ton';
    final tareTimestamp =
        state.autoTareSavedAt ?? state.autoTareDate ?? DateTime.now();
    emit(
      state.copyWith(
        tareWeightKg: tareKg,
        tareWeightText: isTon
            ? (tareKg / 1000).toStringAsFixed(3)
            : tareKg.toStringAsFixed(0),
        tareCapturedAt: tareTimestamp,
        status: BillScreenStatus.loaded,
        clearError: true,
      ),
    );
    recalculateWeights(emit);
  }
}
