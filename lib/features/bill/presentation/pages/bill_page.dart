import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import '../widgets/weight_display.dart';
import '../widgets/bill_form.dart';
import '../widgets/quick_add_customer_dialog.dart';
import '../widgets/quick_add_material_dialog.dart';
import '../widgets/recent_bills_panel.dart';
import '../widgets/weighment_slip_dialog.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final TextEditingController _grossWeightController;
  late final TextEditingController _tareWeightController;
  late final TextEditingController _remarksController;
  late final TextEditingController _vehicleChargeController;
  late final TextEditingController _vehicleNumberController;

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
  String? _lastControllerWeightUnit;
  StreamSubscription<SettingsState>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
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
    final unitChanged = _lastControllerWeightUnit != state.weightUnit;
    final shouldSyncGross =
        unitChanged ||
        (_grossWeightController.text.isEmpty &&
            state.grossWeightText.isNotEmpty);
    final shouldSyncTare =
        unitChanged ||
        (_tareWeightController.text.isEmpty && state.tareWeightText.isNotEmpty);

    if (shouldSyncGross) {
      _setControllerText(_grossWeightController, state.grossWeightText);
    }

    if (shouldSyncTare) {
      _setControllerText(_tareWeightController, state.tareWeightText);
    }

    _lastControllerWeightUnit = state.weightUnit;
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
    if (state.isEditing &&
        state.selectedWeightType.toUpperCase() !=
            state.editingFirstWeightType?.toUpperCase()) {
      _showKeyboardMessage(
        'Only the original ${state.editingFirstWeightType?.toLowerCase()} weight can be changed.',
      );
      return;
    }
    context.read<BillBloc>().add(
      CaptureLiveWeight(type: state.selectedWeightType),
    );
  }

  void _showKeyboardMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showManualTareDialog(BillState state) {
    if (state.isEditing && state.editingFirstWeightType == 'TARE') {
      _showKeyboardMessage('The original tare weight cannot be changed.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ManualTareDialog(
        initialValue: state.tareWeightText,
        weightUnit: state.weightUnit,
        onConfirm: (value) {
          context.read<BillBloc>().add(TareWeightChanged(value));
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  void _captureAutoTare(BillState state) {
    if (!state.liveScaleWeightKg.isFinite || state.liveScaleWeightKg <= 0) {
      _showKeyboardMessage('No valid live scale weight is available.');
      return;
    }
    if (!state.isScaleStable || state.isScaleMotion || state.isScaleOverload) {
      _showKeyboardMessage(
        state.isScaleOverload
            ? 'Scale overload. Tare was not captured.'
            : 'Scale weight is not stable. Tare was not captured.',
      );
      return;
    }
    if (state.isEditing && state.editingFirstWeightType == 'TARE') {
      _showKeyboardMessage('The original tare weight cannot be changed.');
      return;
    }
    context.read<BillBloc>().add(const CaptureLiveWeight(type: 'Tare'));
  }

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
    if (!isSaving && !state.hasWeightError) {
      context.read<BillBloc>().add(const SaveBillRequested());
    }
  }

  void _saveAndPrintTicket(BuildContext context, BillState state) {
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    if (!isSaving && !state.hasWeightError) {
      context.read<BillBloc>().add(const SaveAndPrintBillRequested());
    }
  }

  bool _hasUnsavedData(BillState state) {
    return state.selectedCustomer != null ||
        state.vehicleNumber.isNotEmpty ||
        _vehicleNumberController.text.isNotEmpty ||
        state.selectedMaterial != null ||
        _grossWeightController.text.isNotEmpty ||
        _tareWeightController.text.isNotEmpty ||
        _remarksController.text.isNotEmpty ||
        _vehicleChargeController.text.isNotEmpty;
  }

  void _onReprintPressed(BuildContext context, BillState state) {
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

    showDialog(
      context: context,
      builder: (dialogContext) => WeighmentSlipDialog(
        bill: latestBill,
        customer: customer,
        materialName: material?.name ?? 'â€”',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.errorMessage != curr.errorMessage ||
          prev.currentBillNumber != curr.currentBillNumber ||
          prev.weightUnit != curr.weightUnit ||
          (curr.status == BillScreenStatus.printing &&
              curr.printReceiptBill != null),
      listener: (context, state) {
        _syncWeightControllers(state);

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
      builder: (context, state) {
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            // The weighment page owns these shortcuts; they do not leak
            // into the master, report, or settings pages.
            const SingleActivator(LogicalKeyboardKey.f1): () =>
                _handleF1Workflow(),
            const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
                _saveTicket(context, state),
            const SingleActivator(LogicalKeyboardKey.f2): () =>
                _showManualTareDialog(state),
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                _onCancelPressed(context, state),
            const SingleActivator(LogicalKeyboardKey.f4): () =>
                _onReprintPressed(context, state),
            const SingleActivator(LogicalKeyboardKey.f3): () =>
                _captureAutoTare(state),
            const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
                _saveAndPrintTicket(context, state),
            const SingleActivator(LogicalKeyboardKey.f10): () =>
                _saveAndPrintTicket(context, state),
            const SingleActivator(LogicalKeyboardKey.f9): () =>
                _onExitPressed(context, state),
            const SingleActivator(LogicalKeyboardKey.tab): () =>
                _moveWeighmentFocus(forward: true),
            const SingleActivator(LogicalKeyboardKey.tab, shift: true): () =>
                _moveWeighmentFocus(forward: false),
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF1F5F9),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            WeightDisplay(
                              netWeightKg: state.netWeightKg,
                              grossWeight: state.grossWeightKg,
                              tareWeight: state.tareWeightKg,
                              weightUnit: state.weightUnit,
                              liveScaleWeightKg: state.liveScaleWeightKg,
                              activeMode: state.selectedWeightType
                                  .toUpperCase(),
                              isStable: state.isScaleStable,
                              isMotion: state.isScaleMotion,
                              isOverload: state.isScaleOverload,
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
        );
      },
    );
  }

  Widget _buildWeighmentArea(BillState state, {bool expandForm = false}) {
    final form = _buildBillForm(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeightDisplay(
          netWeightKg: state.netWeightKg,
          grossWeight: state.grossWeightKg,
          tareWeight: state.tareWeightKg,
          weightUnit: state.weightUnit,
          liveScaleWeightKg: state.liveScaleWeightKg,
          activeMode: state.selectedWeightType.toUpperCase(),
          isStable: state.isScaleStable,
          isMotion: state.isScaleMotion,
          isOverload: state.isScaleOverload,
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
    return BillForm(
      billNumber: state.currentBillNumber,
      customers: state.customers,
      materials: state.materials,
      selectedCustomer: state.selectedCustomer,
      vehicleNumber: state.vehicleNumber,
      selectedMaterial: state.selectedMaterial,
      paymentMode: state.paymentMode,
      isEditing: state.isEditing,
      editingFirstWeightType: state.editingFirstWeightType,
      grossWeightController: _grossWeightController,
      tareWeightController: _tareWeightController,
      remarksController: _remarksController,
      vehicleChargeController: _vehicleChargeController,
      vehicleNumberController: _vehicleNumberController,
      grossWeightKg: state.grossWeightKg,
      tareWeightKg: state.tareWeightKg,
      netWeightKg: state.netWeightKg,
      vehicleCharge: state.vehicleCharge,
      amount: state.amount,
      weightUnit: state.weightUnit,
      weightValidationError: state.weightValidationError,
      isReady:
          state.status == BillScreenStatus.loaded ||
          state.status == BillScreenStatus.saved ||
          state.status == BillScreenStatus.error,
      grossCapturedAt: state.grossCapturedAt,
      tareCapturedAt: state.tareCapturedAt,
      selectedType: state.selectedWeightType,
      onTypeChanged: (type) =>
          context.read<BillBloc>().add(WeightTypeSelected(type)),
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
      onCustomerChanged: (customer) =>
          context.read<BillBloc>().add(CustomerSelected(customer)),
      onCustomerCodeSubmitted: (code) =>
          context.read<BillBloc>().findCustomerByCode(code),
      onVehicleNumberChanged: (vehicleNumber) =>
          context.read<BillBloc>().add(VehicleNumberChanged(vehicleNumber)),
      onMaterialChanged: (material) =>
          context.read<BillBloc>().add(MaterialSelected(material)),
      onMaterialCodeSubmitted: (code) =>
          context.read<BillBloc>().findMaterialByCode(code),
      onGrossWeightChanged: (v) =>
          context.read<BillBloc>().add(GrossWeightChanged(v)),
      onTareWeightChanged: (v) =>
          context.read<BillBloc>().add(TareWeightChanged(v)),
      onRemarksChanged: (v) => context.read<BillBloc>().add(RemarksChanged(v)),
      onPaymentModeChanged: (v) =>
          context.read<BillBloc>().add(PaymentModeChanged(v)),
      onWeightUnitChanged: (v) =>
          context.read<BillBloc>().add(WeightUnitChanged(v)),
      onVehicleChargeChanged: (v) =>
          context.read<BillBloc>().add(VehicleChargeChanged(v)),
      onResetVehicleCharge: () =>
          context.read<BillBloc>().add(const ResetVehicleCharge()),
      onAddCustomer: () async {
        final bloc = context.read<BillBloc>();
        final created = await QuickAddCustomerDialog.show(
          context,
          onSave: (name, contactPerson) async {
            return bloc.createCustomer(name, contactPerson ?? '');
          },
        );
        if (created != null && mounted) {
          bloc.add(CustomerSelected(created));
        }
      },
      onAddMaterial: () async {
        final bloc = context.read<BillBloc>();
        final created = await QuickAddMaterialDialog.show(
          context,
          onSave: (code, name) async {
            return bloc.createMaterial(code, name);
          },
        );
        if (created != null && mounted) {
          bloc.add(MaterialSelected(created));
        }
      },
    );
  }

  Widget _buildActionButtons(BillState state) {
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    final isDisabled = isSaving;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Save the completed ticket. F1 is reserved for weight capture.
          _buildPrimaryActionButton(
            icon: Icons.save_rounded,
            label: 'SAVE',
            shortcut: null,
            color: const Color(0xFF16A34A),
            isLoading: isSaving,
            onTap: isDisabled ? null : () => _saveTicket(context, state),
          ),
          // Escape: CANCEL — red filled button
          _buildPrimaryActionButton(
            icon: Icons.cancel_rounded,
            label: 'CANCEL',
            shortcut: 'ESC',
            color: const Color(0xFFDC2626),
            onTap: isSaving ? null : () => _onCancelPressed(context, state),
          ),
          // F4: RE-PRINT
          _buildActionButton(
            icon: Icons.print_rounded,
            iconColor: const Color(0xFF334155),
            label: 'RE-PRINT',
            shortcut: 'F4',
            onTap: () => _onReprintPressed(context, state),
          ),
          // F2: MANUAL TARE
          _buildActionButton(
            icon: Icons.edit_note_rounded,
            iconColor: const Color(0xFF0284C7),
            label: 'MANUAL TARE',
            shortcut: 'F2',
            onTap: isSaving ? null : () => _showManualTareDialog(state),
          ),
          // F3: AUTO TARE
          _buildActionButton(
            icon: Icons.refresh_rounded,
            iconColor: const Color(0xFF0891B2),
            label: 'AUTO TARE',
            shortcut: 'F3',
            onTap: isSaving ? null : () => _captureAutoTare(state),
          ),
          // F9: EXIT current ticket flow
          _buildActionButton(
            icon: Icons.exit_to_app_rounded,
            iconColor: const Color(0xFF475569),
            label: 'EXIT',
            shortcut: 'F9',
            onTap: () => _onExitPressed(context, state),
          ),
        ],
      ),
    );
  }

  /// Filled colour block button for SAVE and CANCEL — matches the reference design.
  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String label,
    String? shortcut,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final isEnabled = onTap != null;
    return Material(
      color: isEnabled ? color : const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 16,
                    color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
                  ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isEnabled
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (shortcut != null)
                      Text(
                        shortcut,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isEnabled
                              ? Colors.white.withValues(alpha: 0.80)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String shortcut,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled
                  ? iconColor.withValues(alpha: 0.40)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(4.5),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? iconColor.withValues(alpha: 0.10)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: isEnabled ? iconColor : const Color(0xFF94A3B8),
                    ),
                  ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isEnabled
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      shortcut,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isEnabled ? iconColor : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCancelPressed(BuildContext context, BillState state) {
    context.read<BillBloc>().add(const ClearBillRequested());
    _syncControllersAfterReset();
  }

  void _onExitPressed(BuildContext context, BillState state) {
    if (!_hasUnsavedData(state)) {
      context.read<BillBloc>().add(const ClearBillRequested());
      _syncControllersAfterReset();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit current weighment?'),
        content: const Text('Unsaved ticket details will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Ticket'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BillBloc>().add(const ClearBillRequested());
              _syncControllersAfterReset();
            },
            child: const Text('Exit Ticket'),
          ),
        ],
      ),
    );
  }
}

class _ManualTareDialog extends StatefulWidget {
  const _ManualTareDialog({
    required this.initialValue,
    required this.weightUnit,
    required this.onConfirm,
  });

  final String initialValue;
  final String weightUnit;
  final ValueChanged<String> onConfirm;

  @override
  State<_ManualTareDialog> createState() => _ManualTareDialogState();
}

class _ManualTareDialogState extends State<_ManualTareDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    widget.onConfirm(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Manual Tare'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        autofocus: true,
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(
          labelText: 'Tare Weight (${widget.weightUnit})',
          border: const OutlineInputBorder(),
        ),
        onFieldSubmitted: (_) => _confirm(),
        validator: (value) {
          final weight = double.tryParse(value?.trim() ?? '');
          if (weight == null || !weight.isFinite || weight <= 0) {
            return 'Enter a valid weight greater than zero';
          }
          return null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _confirm, child: const Text('Confirm')),
    ],
  );
}
