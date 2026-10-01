import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bill_shortcuts.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import '../widgets/live_weight_banner.dart';
import '../widgets/auto_tare_dialog.dart';
import '../widgets/auto_tare_indicator.dart';
import '../widgets/bill_form_binding.dart';
import '../widgets/recent_bills_panel.dart';
import '../widgets/weighment_action_bar.dart';
import '../widgets/weighment_slip_dialog.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../../core/hardware/scale/domain/scale_service.dart';
import '../../../../core/hardware/scale/domain/scale_status.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key, this.isActive = true, this.onExit});

  final bool isActive;
  final VoidCallback? onExit;

  @override
  State<BillPage> createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final FocusNode _keyboardFocusNode;

  late final TextEditingController _grossWeightController;
  late final TextEditingController _tareWeightController;
  late final TextEditingController _remarksController;
  late final TextEditingController _vehicleChargeController;
  late final TextEditingController _vehicleNumberController;

  /// Controllers and focus nodes shared with the form.
  late final BillFormResources _resources;

  late final FocusNode _customerFocusNode;
  late final FocusNode _vehicleFocusNode;
  late final FocusNode _typeFocusNode;
  late final FocusNode _materialFocusNode;
  late final FocusNode _materialCodeFocusNode;
  late final FocusNode _customerCodeFocusNode;
  late final FocusNode _mobileFocusNode;
  late final FocusNode _remarksFocusNode;
  late final FocusNode _grossWeightFocusNode;
  late final FocusNode _tareWeightFocusNode;
  late final FocusNode _vehicleChargeFocusNode;
  late final FocusNode _paymentModeFocusNode;
  late final FocusNode _searchFocusNode;
  bool _didRequestInitialFocus = false;
  bool _isReprintDialogOpen = false;
  bool _isAutoTareDialogOpen = false;
  StreamSubscription<SettingsState>? _settingsSubscription;
  StreamSubscription<ScaleReading>? _scaleReadingSubscription;
  StreamSubscription<ScaleStatus>? _scaleStatusSubscription;

  void requestFocus() {
    if (!mounted || !widget.isActive) return;
    if (_vehicleNumberController.text.isEmpty) {
      _vehicleFocusNode.requestFocus();
    } else {
      _keyboardFocusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant BillPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        requestFocus();
      });
    }
  }

  bool get _isModalOpen {
    if (!mounted) return true;
    final modalRoute = ModalRoute.of(context);
    return modalRoute != null && !modalRoute.isCurrent;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    _keyboardFocusNode = FocusNode(
      debugLabel: 'weighmentKeyboardFocusNode',
      skipTraversal: true,
    );
    _grossWeightController = TextEditingController();
    _tareWeightController = TextEditingController();
    _remarksController = TextEditingController();
    _vehicleChargeController = TextEditingController();
    _vehicleNumberController = TextEditingController();

    _customerFocusNode = FocusNode(debugLabel: 'customerFocusNode');
    _vehicleFocusNode = FocusNode(debugLabel: 'vehicleFocusNode');
    _typeFocusNode = FocusNode(debugLabel: 'weightTypeFocusNode');
    _materialFocusNode = FocusNode(debugLabel: 'materialFocusNode');
    _materialCodeFocusNode = FocusNode(debugLabel: 'materialCodeFocusNode');
    _customerCodeFocusNode = FocusNode(debugLabel: 'customerCodeFocusNode');
    _mobileFocusNode = FocusNode(debugLabel: 'mobileFocusNode');
    _remarksFocusNode = FocusNode(debugLabel: 'remarksFocusNode');
    _grossWeightFocusNode = FocusNode(debugLabel: 'grossWeightFocusNode');
    _tareWeightFocusNode = FocusNode(debugLabel: 'tareWeightFocusNode');
    _vehicleChargeFocusNode = FocusNode(debugLabel: 'vehicleChargeFocusNode');
    _paymentModeFocusNode = FocusNode(debugLabel: 'paymentModeFocusNode');
    _searchFocusNode = FocusNode(debugLabel: 'searchFocusNode');
    _resources = BillFormResources(
      grossWeightController: _grossWeightController,
      tareWeightController: _tareWeightController,
      remarksController: _remarksController,
      vehicleChargeController: _vehicleChargeController,
      vehicleNumberController: _vehicleNumberController,
      customerFocusNode: _customerFocusNode,
      vehicleFocusNode: _vehicleFocusNode,
      typeFocusNode: _typeFocusNode,
      materialFocusNode: _materialFocusNode,
      materialCodeFocusNode: _materialCodeFocusNode,
      customerCodeFocusNode: _customerCodeFocusNode,
      mobileFocusNode: _mobileFocusNode,
      remarksFocusNode: _remarksFocusNode,
      grossWeightFocusNode: _grossWeightFocusNode,
      tareWeightFocusNode: _tareWeightFocusNode,
      vehicleChargeFocusNode: _vehicleChargeFocusNode,
      paymentModeFocusNode: _paymentModeFocusNode,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
        context.read<BillBloc>().add(const LoadBillScreen());
        try {
          _settingsSubscription = context.read<SettingsBloc>().stream.listen((
            state,
          ) {
            final unit = state.settings?.weightUnit;
            if (mounted && unit != null) {
              context.read<BillBloc>().add(WeightUnitChanged(unit));
            }
          });
        } catch (_) {
          // Standalone page previews may not provide application settings.
        }
        try {
          final scaleService = context.read<ScaleService>();
          final currentStatus = scaleService.currentStatus;
          if (currentStatus.currentWeightKg != null) {
            context.read<BillBloc>().add(
              LiveScaleWeightUpdated(
                weightKg: currentStatus.currentWeightKg!,
                isStable: currentStatus.stable,
                isMotion: currentStatus.isMotion,
                isOverload: currentStatus.isOverload,
              ),
            );
          }
          _scaleReadingSubscription = scaleService.weightStream.listen((
            reading,
          ) {
            if (!mounted) return;
            context.read<BillBloc>().add(
              LiveScaleWeightUpdated(
                weightKg: reading.weightKg,
                isStable: reading.stable,
                isMotion: reading.isMotion,
                isOverload: reading.isOverload,
              ),
            );
          });
          _scaleStatusSubscription = scaleService.statusStream.listen((status) {
            if (!mounted || status.isConnected) return;
            // Port dropped: clear the live reading so stale weights are never
            // captured or shown as current.
            if (status.isTransitioning) return;
            context.read<BillBloc>().add(
              LiveScaleWeightUpdated(
                weightKg: 0,
                isStable: false,
                isMotion: true,
              ),
            );
          });
        } catch (_) {
          // Scale not provided in standalone page previews.
        }
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    _settingsSubscription?.cancel();
    _scaleReadingSubscription?.cancel();
    _scaleStatusSubscription?.cancel();
    _keyboardFocusNode.dispose();
    _grossWeightController.dispose();
    _tareWeightController.dispose();
    _remarksController.dispose();
    _vehicleChargeController.dispose();
    _vehicleNumberController.dispose();

    _customerFocusNode.dispose();
    _vehicleFocusNode.dispose();
    _typeFocusNode.dispose();
    _materialFocusNode.dispose();
    _materialCodeFocusNode.dispose();
    _customerCodeFocusNode.dispose();
    _mobileFocusNode.dispose();
    _remarksFocusNode.dispose();
    _grossWeightFocusNode.dispose();
    _tareWeightFocusNode.dispose();
    _vehicleChargeFocusNode.dispose();
    _paymentModeFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _syncControllersAfterReset() {
    _grossWeightController.clear();
    _tareWeightController.clear();
    _remarksController.clear();
    _vehicleChargeController.clear();
    _vehicleNumberController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _vehicleFocusNode.requestFocus();
      }
    });
  }

  void _syncWeightControllers(BillState state) {
    _setControllerText(_grossWeightController, state.grossWeightText);
    _setControllerText(_tareWeightController, state.tareWeightText);
    _setControllerText(_vehicleNumberController, state.vehicleNumber);
    _setControllerText(_remarksController, state.remarksText);
    if (state.vehicleCharge > 0) {
      _setControllerText(
        _vehicleChargeController,
        state.vehicleCharge == state.vehicleCharge.roundToDouble()
            ? state.vehicleCharge.toStringAsFixed(0)
            : state.vehicleCharge.toStringAsFixed(2),
      );
    }
  }

  void _setControllerText(TextEditingController controller, String text) {
    if (controller.text == text) {
      return;
    }

    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _handleF1Workflow() {
    final state = context.read<BillBloc>().state;
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    if (isSaving) return;
    final vehicleNumber = _vehicleNumberController.text.trim();
    if (vehicleNumber.length != 10 ||
        !RegExp(r'^[A-Z0-9]{10}$').hasMatch(vehicleNumber)) {
      _showKeyboardMessage('Truck number must be exactly 10 characters.');
      _vehicleFocusNode.requestFocus();
      return;
    }
    final requiredType = state.hasBothWeights
        ? state.editingFirstWeightType?.toUpperCase()
        : (state.editingFirstWeightType?.toUpperCase() == 'GROSS'
              ? 'TARE'
              : 'GROSS');
    if (state.isEditing &&
        state.selectedWeightType.toUpperCase() != requiredType) {
      _showKeyboardMessage(
        'Capture the missing ${requiredType?.toLowerCase()} weight to continue this ticket.',
      );
      return;
    }
    context.read<BillBloc>().add(
      CaptureLiveWeight(type: state.selectedWeightType),
    );
    if (!state.hasAutoTare &&
        state.selectedWeightType.toUpperCase() == 'GROSS') {
      // Never fall back to yesterday's tare: tell the operator explicitly.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifyAutoTareNotSet();
      });
    }
  }

  /// Today's auto tare is missing. Never fall back to yesterday's value:
  /// tell the operator instead. This is a non-blocking notice so an ongoing
  /// weighment (manual tare, second weighing) is never interrupted.
  void _notifyAutoTareNotSet() {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            "Auto Tare Not Set. Set today's Auto Tare with F3 to use it "
            "automatically.",
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF0D3B82),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Set Auto Tare',
            textColor: Colors.white,
            onPressed: _openAutoTareDialog,
          ),
        ),
      );
  }

  /// F3 - AUTO TARE opens the day's common tare management screen.
  Future<void> _openAutoTareDialog() async {
    if (_isAutoTareDialogOpen) return;
    _isAutoTareDialogOpen = true;
    final bloc = context.read<BillBloc>();
    try {
      await AutoTareDialog.show(
        context,
        currentAutoTareKg: bloc.state.autoTareKg,
        liveScaleWeightKg: bloc.state.liveScaleWeightKg,
        isScaleStable: bloc.state.isScaleStable,
        isScaleMotion: bloc.state.isScaleMotion,
        isScaleOverload: bloc.state.isScaleOverload,
        weightUnit: bloc.state.weightUnit,
        onSave: (tareKg) => _runAutoTareWrite(
          (completer) => SaveAutoTare(tareKg, completer: completer),
        ),
        onDelete: () => _runAutoTareWrite(
          (completer) => DeleteAutoTare(completer: completer),
        ),
      );
    } finally {
      _isAutoTareDialogOpen = false;
    }
  }

  /// Dispatches an auto tare write and completes once the bloc handles it.
  ///
  /// Waiting on the state stream instead would hang whenever the write
  /// produces no new state, which is exactly what happens when the saved
  /// value already matches the stored one.
  Future<void> _runAutoTareWrite(
    BillEvent Function(Completer<void>) event,
  ) async {
    final bloc = context.read<BillBloc>();
    final completer = Completer<void>();
    bloc.add(event(completer));
    await completer.future;
  }

  void _showKeyboardMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _focusTareWeightInput() {
    _tareWeightFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_tareWeightFocusNode.hasFocus) return;
      _tareWeightController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _tareWeightController.text.length,
      );
    });
  }

  void focusTareWeightInput() => _focusTareWeightInput();

  void _moveWeighmentFocus({required bool forward}) {
    final nodes = [
      _vehicleFocusNode,
      _typeFocusNode,
      _materialCodeFocusNode,
      _customerCodeFocusNode,
      _vehicleChargeFocusNode,
      _remarksFocusNode,
      _mobileFocusNode,
    ];
    final currentFocus = FocusManager.instance.primaryFocus;
    final currentIndex = currentFocus == null
        ? -1
        : nodes.indexOf(currentFocus);
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + (forward ? 1 : -1) + nodes.length) % nodes.length;
    nodes[nextIndex].requestFocus();
  }

  void _saveTicket(BuildContext context, BillState state) {
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    if (!isSaving) {
      context.read<BillBloc>().add(const SaveAndPrintBillRequested());
    }
  }

  void _saveAndPrintTicket(BuildContext context, BillState state) {
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    if (!isSaving) {
      context.read<BillBloc>().add(const SaveAndPrintBillRequested());
    }
  }

  void _focusFirstInvalidField(Map<String, String> errors) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (errors.containsKey('vehicleNumber')) {
        _vehicleFocusNode.requestFocus();
      } else if (errors.containsKey('material')) {
        _materialCodeFocusNode.requestFocus();
      } else if (errors.containsKey('customer')) {
        _customerCodeFocusNode.requestFocus();
      } else if (errors.containsKey('charges')) {
        _vehicleChargeFocusNode.requestFocus();
      } else if (errors.containsKey('weight')) {
        _grossWeightFocusNode.requestFocus();
      } else if (errors.containsKey('mobile')) {
        _mobileFocusNode.requestFocus();
      }
    });
  }

  bool _hasUnsavedData(BillState state) {
    return state.selectedCustomer != null ||
        state.vehicleNumber.isNotEmpty ||
        _vehicleNumberController.text.isNotEmpty ||
        state.selectedMaterial != null ||
        state.grossWeightKg > 0 ||
        state.tareWeightKg > 0 ||
        state.vehicleCharge > 0 ||
        state.amount > 0 ||
        state.remarksText.isNotEmpty ||
        _grossWeightController.text.isNotEmpty ||
        _tareWeightController.text.isNotEmpty ||
        _remarksController.text.isNotEmpty ||
        _vehicleChargeController.text.isNotEmpty;
  }

  void _onReprintPressed(BuildContext context, BillState state) {
    if (_isReprintDialogOpen) return;

    final completedBills = state.recentBills
        .where((b) => b.isCompleted)
        .toList();
    if (completedBills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No ticket available for reprint.'),
          backgroundColor: Colors.blueGrey.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show selection dialog or reprint most recent bill
    final latestBill = completedBills.first;
    final customer = state.customers
        .where((c) => c.id == latestBill.customerId)
        .firstOrNull;
    final material = state.materials
        .where((m) => m.id == latestBill.materialId)
        .firstOrNull;

    _isReprintDialogOpen = true;
    showDialog(
      context: context,
      builder: (dialogContext) => WeighmentSlipDialog(
        bill: latestBill,
        customer: customer,
        materialName: material?.name ?? '—',
      ),
    ).whenComplete(() {
      _isReprintDialogOpen = false;
    });
  }

  /// Skips the page rebuild when the only change is the live scale reading.
  ///
  /// The indicator streams weight continuously; [LiveWeightBanner] owns that
  /// traffic, so the form, recent billings, and action bar stay untouched while
  /// the weight only moves.
  bool shouldRebuildBillScreen(BillState previous, BillState current) {
    final previousIgnoringLive = previous.copyWith(
      liveScaleWeightKg: current.liveScaleWeightKg,
      isScaleStable: current.isScaleStable,
      isScaleMotion: current.isScaleMotion,
      isScaleOverload: current.isScaleOverload,
    );
    return previousIgnoringLive != current;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.errorMessage != curr.errorMessage ||
          prev.fieldErrors != curr.fieldErrors ||
          prev.currentBillNumber != curr.currentBillNumber ||
          prev.weightUnit != curr.weightUnit ||
          prev.grossWeightText != curr.grossWeightText ||
          prev.tareWeightText != curr.tareWeightText ||
          prev.vehicleNumber != curr.vehicleNumber ||
          prev.remarksText != curr.remarksText ||
          prev.vehicleCharge != curr.vehicleCharge ||
          prev.editingBillId != curr.editingBillId ||
          prev.autoTareKg != curr.autoTareKg ||
          prev.autoTareDate != curr.autoTareDate ||
          (curr.status == BillScreenStatus.printing &&
              curr.printReceiptBill != null),
      listener: (context, state) {
        _syncWeightControllers(state);

        if (state.hasFieldErrors) {
          _focusFirstInvalidField(state.fieldErrors);
        }

        if (!_didRequestInitialFocus &&
            state.status == BillScreenStatus.loaded) {
          _didRequestInitialFocus = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _vehicleFocusNode.requestFocus();
            }
          });
        }
        if (state.status == BillScreenStatus.printing &&
            state.printReceiptBill != null) {
          _syncControllersAfterReset();
          final bill = state.printReceiptBill!;
          final customer = state.printReceiptCustomer;
          final materialName = state.printReceiptMaterialName ?? 'â€”';
          context.read<BillBloc>().add(const PrintReceiptDismissed());
          showDialog(
            context: context,
            builder: (dialogContext) => WeighmentSlipDialog(
              bill: bill,
              customer: customer,
              materialName: materialName,
            ),
          );
        }
        if (state.status == BillScreenStatus.saved) {
          _syncControllersAfterReset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Bill ${state.currentBillNumber} saved successfully!',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        if (state.status == BillScreenStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      buildWhen: shouldRebuildBillScreen,
      builder: (context, state) {
        return WeighmentShortcutScope(
          handlers: _buildShortcutHandlers(),
          child: Focus(
            autofocus: true,
            focusNode: _keyboardFocusNode,
            skipTraversal: true,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: const Color(0xFFF1F5F9),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 1280) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildWeighmentArea(state),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 440,
                              child: _buildRecentBillsPanel(state),
                            ),
                          ],
                        ),
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── LEFT PANEL: Weight Display + Form + Action Buttons ──
                        Expanded(
                          flex: 67,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Hero Weight Display Banner
                              const LiveWeightBanner(),

                              // Auto tare indicator for the current day
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AutoTareIndicator(
                                    autoTareKg: state.autoTareKg,
                                    weightUnit: state.weightUnit,
                                    autoTareDate: state.autoTareDate,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // 2. Main 2-Column Form
                              Expanded(child: _buildBillForm(state)),

                              const SizedBox(height: 10),

                              // 3. Action Buttons Bar
                              _buildActionButtons(state),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ── RIGHT PANEL: Always-visible Recent Bills ──
                        Expanded(
                          flex: 33,
                          child: RecentBillsPanel(
                            searchFocusNode: _searchFocusNode,
                            recentBills: state.recentBills,
                            billsDate: state.effectiveBillsDate,
                            billsStartDate: state.billsStartDate,
                            billsEndDate: state.billsEndDate,
                            customers: state.customers,
                            materials: state.materials,
                            weightUnit: state.weightUnit,
                            onBillSelected: (bill) {
                              context.read<BillBloc>().add(
                                LoadBillForEdit(bill),
                              );
                            },
                            onDateChanged: (date) {
                              context.read<BillBloc>().add(
                                LoadRecentBills(date: date),
                              );
                            },
                            onDateRangeChanged: (startDate, endDate) {
                              if (startDate != null && endDate != null) {
                                context.read<BillBloc>().add(
                                  LoadRecentBills(
                                    startDate: startDate,
                                    endDate: endDate,
                                  ),
                                );
                              } else {
                                context.read<BillBloc>().add(
                                  const LoadRecentBills(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Routes hardware key events through the shared global handler.
  ///
  /// Registered for the page's lifetime; the logic itself lives in
  /// `bill_shortcuts.dart` alongside the [Shortcuts] widget it runs next to.
  bool _handleGlobalKeyEvent(KeyEvent event) {
    return handleWeighmentGlobalKeyEvent(
      event,
      isMounted: mounted,
      isActive: widget.isActive,
      isModalOpen: _isModalOpen,
      isSaving: () => _isStatusBusy(context.read<BillBloc>().state),
      onCancel: () => _onCancelPressed(context, context.read<BillBloc>().state),
      onSave: () => _saveTicket(context, context.read<BillBloc>().state),
      onCaptureLiveWeight: _handleF1Workflow,
      onManualTare: _focusTareWeightInput,
      onAutoTare: _openAutoTareDialog,
      onReprint: () =>
          _onReprintPressed(context, context.read<BillBloc>().state),
      onExit: widget.onExit,
      onSaveAndPrint: () =>
          _saveAndPrintTicket(context, context.read<BillBloc>().state),
    );
  }

  WeighmentShortcutHandlers _buildShortcutHandlers() {
    return WeighmentShortcutHandlers(
      isModalOpen: () => _isModalOpen,
      isSaving: () => _isStatusBusy(context.read<BillBloc>().state),
      onCancel: () => _onCancelPressed(context, context.read<BillBloc>().state),
      onSave: () => _saveTicket(context, context.read<BillBloc>().state),
      onCaptureLiveWeight: _handleF1Workflow,
      onManualTare: _focusTareWeightInput,
      onAutoTare: _openAutoTareDialog,
      onReprint: () =>
          _onReprintPressed(context, context.read<BillBloc>().state),
      onExit: widget.onExit,
      onSaveAndPrint: () =>
          _saveAndPrintTicket(context, context.read<BillBloc>().state),
      onNextField: () => _moveWeighmentFocus(forward: true),
      onPreviousField: () => _moveWeighmentFocus(forward: false),
    );
  }

  static bool _isStatusBusy(BillState state) =>
      state.status == BillScreenStatus.saving ||
      state.status == BillScreenStatus.printing;

  Widget _buildWeighmentArea(BillState state, {bool expandForm = false}) {
    final form = _buildBillForm(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LiveWeightBanner(),
        Align(
          alignment: Alignment.centerRight,
          child: AutoTareIndicator(
            autoTareKg: state.autoTareKg,
            weightUnit: state.weightUnit,
            autoTareDate: state.autoTareDate,
          ),
        ),
        const SizedBox(height: 10),
        if (expandForm) Expanded(child: form) else form,
        const SizedBox(height: 10),
        _buildActionButtons(state),
      ],
    );
  }

  Widget _buildRecentBillsPanel(BillState state) {
    return RecentBillsPanel(
      searchFocusNode: _searchFocusNode,
      recentBills: state.recentBills,
      billsDate: state.effectiveBillsDate,
      billsStartDate: state.billsStartDate,
      billsEndDate: state.billsEndDate,
      customers: state.customers,
      materials: state.materials,
      weightUnit: state.weightUnit,
      onBillSelected: (bill) {
        context.read<BillBloc>().add(LoadBillForEdit(bill));
      },
      onDateChanged: (date) {
        context.read<BillBloc>().add(LoadRecentBills(date: date));
      },
      onDateRangeChanged: (startDate, endDate) {
        if (startDate != null && endDate != null) {
          context.read<BillBloc>().add(
            LoadRecentBills(startDate: startDate, endDate: endDate),
          );
        } else {
          context.read<BillBloc>().add(const LoadRecentBills());
        }
      },
    );
  }

  Widget _buildBillForm(BillState state) {
    return BillFormBinding(state: state, resources: _resources);
  }

  Widget _buildActionButtons(BillState state) {
    return WeighmentActionBar(
      isSaving: _isStatusBusy(state),
      onSave: () => _saveTicket(context, state),
      onCancel: () => _onCancelPressed(context, state),
      onRegisterWeight: _handleF1Workflow,
      onManualTare: _focusTareWeightInput,
      onAutoTare: _openAutoTareDialog,
      onReprint: () => _onReprintPressed(context, state),
    );
  }

  Future<void> _onCancelPressed(BuildContext context, BillState state) async {
    if (_hasUnsavedData(state)) {
      final shouldCancel = await ConfirmActionDialog.show(
        context: context,
        title: 'Cancel Weighment?',
        message: 'All entered information will be cleared.',
        warningNote:
            'Unsaved vehicle weights and form entries will be permanently lost.',
        cancelLabel: 'Keep Editing',
        confirmLabel: 'Cancel Weighment',
        confirmIcon: Icons.delete_outline_rounded,
        icon: Icons.delete_sweep_outlined,
        isDanger: true,
      );
      if (shouldCancel != true || !context.mounted) return;
    }

    context.read<BillBloc>().add(const ClearBillRequested());
    _syncControllersAfterReset();
  }
}
