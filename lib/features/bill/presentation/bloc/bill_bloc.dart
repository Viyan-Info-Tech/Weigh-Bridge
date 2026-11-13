import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../../material/domain/repositories/material_repository.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/usecases/save_bill.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import 'bill_event.dart';
import 'bill_state.dart';

part 'bill_bloc_loading.dart';
part 'bill_bloc_vehicle.dart';
part 'bill_bloc_weights.dart';
part 'bill_bloc_form.dart';
part 'bill_bloc_validation.dart';
part 'bill_bloc_save.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;

  /// Looks up the previous single-weight bill of a returning truck.
  ///
  /// Optional so older unit tests that construct the bloc without it keep
  /// compiling; without it the SECOND WEIGHT lookup reports no match.
  final GetPreviousWeighmentUseCase? _previousWeighmentUseCase;
  final SettingsRepository? _settingsRepository;

  /// Monotonic token for previous-weighment lookups.
  ///
  /// Vehicle-number edits fire a lookup per change, so two lookups can be in
  /// flight at once against the default concurrent transformer. A result is
  /// applied only while its token is still the newest, which stops a slow
  /// query for an earlier vehicle number from repopulating stale weights
  /// after a newer one already answered.
  int _previousWeightLookupSeq = 0;

  /// Master data for the material dropdown. When null (e.g. in older unit
  /// tests that don't wire it), the material field falls back to plain text.
  final MaterialRepository? _materialRepository;

  /// The form as it stood immediately after the last successful save.
  ///
  /// One Ctrl+S dispatches `SaveAndPrintBillRequested` twice, because
  /// `BillPage` registers both a raw `HardwareKeyboard` handler and a
  /// `Shortcuts` widget and the two key systems are independent. The UI-level
  /// `isSaving()` check cannot catch the duplicate: both events are queued
  /// before the bloc processes the first one, so the status is still `loaded`
  /// when the second is handled.
  ///
  /// Left unguarded, the first event saves and resets the form and the second
  /// then validates the now-empty form, painting a wall of red errors behind
  /// the receipt preview.
  ///
  /// The duplicate is recognised by the *form* rather than by a flag or by the
  /// receipt, because the two key systems can fire in different event-loop
  /// turns. `BillPage` also dispatches `PrintReceiptDismissed` the moment the
  /// preview opens, so a receipt-based check only holds if the duplicate
  /// happens to arrive before that. Comparing the form holds regardless of
  /// ordering: a request that arrives while the form still looks exactly like
  /// the one that was just saved can only be that duplicate, because an empty
  /// form can never pass validation anyway.
  BillState? _formJustSaved;

  /// True when [state] is still untouched since the last successful save.

  BillBloc({
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
    GetPreviousWeighmentUseCase? previousWeighmentUseCase,
    SettingsRepository? settingsRepository,
    MaterialRepository? materialRepository,
  }) : _saveBillUseCase = saveBillUseCase,
       _loadRecentBillsUseCase = loadRecentBillsUseCase,
       _generateBillNumberUseCase = generateBillNumberUseCase,
       _previousWeighmentUseCase = previousWeighmentUseCase,
       _settingsRepository = settingsRepository,
       _materialRepository = materialRepository,
       super(const BillState()) {
    on<LoadBillScreen>(_onLoadBillScreen);
    on<RefreshBillLookups>(_onRefreshBillLookups);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<GrossWeightChanged>(_onGrossWeightChanged);
    on<TareWeightChanged>(_onTareWeightChanged);
    on<GrossWeightCommitted>(_onGrossWeightCommitted);
    on<TareWeightCommitted>(_onTareWeightCommitted);
    on<GrossCapturedAtChanged>(_onGrossCapturedAtChanged);
    on<TareCapturedAtChanged>(_onTareCapturedAtChanged);
    on<RemarksChanged>(_onRemarksChanged);
    on<MaterialChanged>(_onMaterialChanged);
    on<ChargesChanged>(_onChargesChanged);
    on<WeightUnitChanged>(_onWeightUnitChanged);
    // Saves run one at a time. The default concurrent transformer would let a
    // double tap on SAVE (or F5 plus a click) run two inserts against the same
    // form state, which is how duplicate bill numbers were being produced.
    on<SaveBillRequested>(_onSaveBillRequested, transformer: _sequential());
    on<SaveAndPrintBillRequested>(
      _onSaveAndPrintBillRequested,
      transformer: _sequential(),
    );
    on<PrintReceiptDismissed>(_onPrintReceiptDismissed);
    on<ClearBillRequested>(_onClearBillRequested, transformer: _sequential());
    on<LoadRecentBills>(_onLoadRecentBills);
    on<CaptureLiveWeight>(_onCaptureLiveWeight);
    on<LiveScaleWeightUpdated>(_onLiveScaleWeightUpdated);
    on<WeightTypeSelected>(_onWeightTypeSelected);
    on<MobileNumberChanged>(_onMobileNumberChanged);
    on<SecondWeightModeChanged>(_onSecondWeightModeChanged);
    on<FetchPreviousWeightForVehicle>(_onFetchPreviousWeightForVehicle);
  }

  /// Processes one event at a time for handlers that must not overlap.
  static EventTransformer<T> _sequential<T>() {
    return (events, mapper) => events.asyncExpand(mapper);
  }
}
