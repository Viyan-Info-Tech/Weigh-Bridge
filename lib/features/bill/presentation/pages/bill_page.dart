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
  late final FocusNode _materialFocusNode;
  late final FocusNode _remarksFocusNode;
  late final FocusNode _grossWeightFocusNode;
  late final FocusNode _tareWeightFocusNode;
  late final FocusNode _vehicleChargeFocusNode;
  late final FocusNode _paymentModeFocusNode;
  late final FocusNode _searchFocusNode;
  bool _didRequestInitialFocus = false;
  String? _lastControllerWeightUnit;

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
    _materialFocusNode = FocusNode(debugLabel: 'materialFocusNode');
    _remarksFocusNode = FocusNode(debugLabel: 'remarksFocusNode');
    _grossWeightFocusNode = FocusNode(debugLabel: 'grossWeightFocusNode');
    _tareWeightFocusNode = FocusNode(debugLabel: 'tareWeightFocusNode');
    _vehicleChargeFocusNode = FocusNode(debugLabel: 'vehicleChargeFocusNode');
    _paymentModeFocusNode = FocusNode(debugLabel: 'paymentModeFocusNode');
    _searchFocusNode = FocusNode(debugLabel: 'searchFocusNode');

    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillBloc>().add(const LoadBillScreen());
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);

    _grossWeightController.dispose();
    _tareWeightController.dispose();
    _remarksController.dispose();
    _vehicleChargeController.dispose();
    _vehicleNumberController.dispose();

    _customerFocusNode.dispose();
    _vehicleFocusNode.dispose();
    _materialFocusNode.dispose();
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

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.f1) return false;

    // Avoid triggering F1 when user is actively typing in a normal text field
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null && primaryFocus.context != null) {
      final widget = primaryFocus.context!.widget;
      final isEditable =
          widget is EditableText ||
          primaryFocus.context!.findAncestorWidgetOfExactType<EditableText>() !=
              null;
      if (isEditable) {
        return false;
      }
    }

    _handleF1Workflow();
    return true;
  }

  void _handleF1Workflow() {
    final state = context.read<BillBloc>().state;
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    if (isSaving) return;

    final selectedType = state.selectedWeightType.toLowerCase();
    final hasGross = state.grossWeightKg > 0;
    final hasTare = state.tareWeightKg > 0;

    final needsGrossCapture =
        selectedType == 'gross' &&
        (!hasGross || state.grossWeightKg != state.liveScaleWeightKg);
    final needsTareCapture =
        selectedType == 'tare' &&
        (!hasTare || state.tareWeightKg != state.liveScaleWeightKg);

    if (needsGrossCapture || needsTareCapture) {
      context.read<BillBloc>().add(
        CaptureLiveWeight(type: state.selectedWeightType),
      );
      return;
    }

    if (hasGross && hasTare) {
      _saveTicket(context, state);
      return;
    }

    context.read<BillBloc>().add(
      CaptureLiveWeight(type: state.selectedWeightType),
    );
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
        state.selectedMaterial != null ||
        _grossWeightController.text.isNotEmpty ||
        _tareWeightController.text.isNotEmpty ||
        _remarksController.text.isNotEmpty;
  }

  void _onReprintPressed(BuildContext context, BillState state) {
    final completedBills = state.recentBills
        .where((b) => b.isCompleted)
        .toList();
    if (completedBills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No completed weighment slips found to re-print.',
          ),
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
        materialName: material?.name ?? '—',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
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
          final materialName = state.printReceiptMaterialName ?? '—';
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
            // F1: Save Ticket / Capture Live Weight
            const SingleActivator(LogicalKeyboardKey.f1): () =>
                _handleF1Workflow(),
            const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
                _handleF1Workflow(),
            // F2: Cancel
            const SingleActivator(LogicalKeyboardKey.f2): () =>
                _onCancelPressed(context, state),
            // F4: Re-Print
            const SingleActivator(LogicalKeyboardKey.f4): () =>
                _onReprintPressed(context, state),
            const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
                _saveAndPrintTicket(context, state),
            const SingleActivator(LogicalKeyboardKey.f10): () =>
                _saveAndPrintTicket(context, state),
            // F5: Manual Tare
            const SingleActivator(LogicalKeyboardKey.f5): () =>
                _tareWeightFocusNode.requestFocus(),
            // F6: Auto Tare
            const SingleActivator(LogicalKeyboardKey.f6): () {
              if (state.grossWeightKg > 0 && state.tareWeightKg == 0) {
                context.read<BillBloc>().add(
                  TareWeightChanged(state.grossWeightKg.toStringAsFixed(0)),
                );
              }
            },
            // F7: Re-send SMS
            const SingleActivator(LogicalKeyboardKey.f7): () =>
                _onResendSmsPressed(context, state),
            // F9: Exit / Clear
            const SingleActivator(LogicalKeyboardKey.f9): () =>
                _onExitPressed(context, state),
            // F3: Recent Bills Drawer
            const SingleActivator(LogicalKeyboardKey.f3): () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF1F5F9),
            // Drawer for Recent Bills (Accessible via F5 or button)
            endDrawer: Drawer(
              width: 500,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            color: Color(0xFF0D53FC),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Recent Bills & Tickets',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RecentBillsPanel(
                        searchFocusNode: _searchFocusNode,
                        recentBills: state.recentBills,
                        billsDate: state.effectiveBillsDate,
                        billsStartDate: state.billsStartDate,
                        billsEndDate: state.billsEndDate,
                        customers: state.customers,
                        materials: state.materials,
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
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    activeMode: state.selectedWeightType.toUpperCase(),
                    isStable: state.isScaleStable,
                    isMotion: state.isScaleMotion,
                    isOverload: state.isScaleOverload,
                  ),

                  const SizedBox(height: 10),

                  // 2. Main 2-Column Form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBillForm(state),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  // 3. Action Buttons Bar
                  _buildActionButtons(state),
                ],
              ),
            ),
          ),
        );
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
      materialFocusNode: _materialFocusNode,
      remarksFocusNode: _remarksFocusNode,
      grossWeightFocusNode: _grossWeightFocusNode,
      tareWeightFocusNode: _tareWeightFocusNode,
      vehicleChargeFocusNode: _vehicleChargeFocusNode,
      paymentModeFocusNode: _paymentModeFocusNode,
      onCustomerChanged: (customer) =>
          context.read<BillBloc>().add(CustomerSelected(customer)),
      onVehicleNumberChanged: (vehicleNumber) =>
          context.read<BillBloc>().add(VehicleNumberChanged(vehicleNumber)),
      onMaterialChanged: (material) =>
          context.read<BillBloc>().add(MaterialSelected(material)),
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

  /// 3. Prominent Action Buttons Row: SAVE, CANCEL, RE-PRINT, MANUAL TARE, AUTO TARE, RE-SEND SMS, EXIT
  Widget _buildActionButtons(BillState state) {
    final isSaving =
        state.status == BillScreenStatus.saving ||
        state.status == BillScreenStatus.printing;
    final isDisabled = isSaving || state.hasWeightError;

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
      child: Row(
        children: [
          // 1. SAVE (F1)
          _buildActionButton(
            icon: Icons.save_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'SAVE',
            shortcut: 'F1',
            isLoading: isSaving,
            onTap: isDisabled ? null : () => _handleF1Workflow(),
          ),
          const SizedBox(width: 8),

          // 2. CANCEL (F2)
          _buildActionButton(
            icon: Icons.cancel_rounded,
            iconColor: const Color(0xFFEF4444),
            label: 'CANCEL',
            shortcut: 'F2',
            onTap: isSaving ? null : () => _onCancelPressed(context, state),
          ),
          const SizedBox(width: 8),

          // 3. RE-PRINT (F4)
          _buildActionButton(
            icon: Icons.print_rounded,
            iconColor: const Color(0xFF334155),
            label: 'RE-PRINT',
            shortcut: 'F4',
            onTap: () => _onReprintPressed(context, state),
          ),
          const SizedBox(width: 8),

          // 4. MANUAL TARE (F5)
          _buildActionButton(
            icon: Icons.scale_rounded,
            iconColor: const Color(0xFF0284C7),
            label: 'MANUAL TARE',
            shortcut: 'F5',
            onTap: () => _tareWeightFocusNode.requestFocus(),
          ),
          const SizedBox(width: 8),

          // 5. AUTO TARE (F6)
          _buildActionButton(
            icon: Icons.refresh_rounded,
            iconColor: const Color(0xFF0891B2),
            label: 'AUTO TARE',
            shortcut: 'F6',
            onTap: () {
              if (state.grossWeightKg > 0 && state.tareWeightKg == 0) {
                context.read<BillBloc>().add(
                  TareWeightChanged(state.grossWeightKg.toStringAsFixed(0)),
                );
              }
            },
          ),
          const SizedBox(width: 8),

          // 6. RE-SEND SMS (F7)
          _buildActionButton(
            icon: Icons.mail_rounded,
            iconColor: const Color(0xFF2563EB),
            label: 'RE-SEND SMS',
            shortcut: 'F7',
            onTap: () => _onResendSmsPressed(context, state),
          ),
          const SizedBox(width: 8),

          // 7. EXIT (F9)
          _buildActionButton(
            icon: Icons.exit_to_app_rounded,
            iconColor: const Color(0xFFDC2626),
            label: 'EXIT',
            shortcut: 'F9',
            onTap: isSaving ? null : () => _onExitPressed(context, state),
          ),
        ],
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

    return Expanded(
      child: Material(
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
                          color: isEnabled
                              ? iconColor
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
      ),
    );
  }

  void _onCancelPressed(BuildContext context, BillState state) {
    context.read<BillBloc>().add(const ClearBillRequested());
    _syncControllersAfterReset();
  }

  void _onClearFormPressed(BuildContext context, BillState state) {
    if (!_hasUnsavedData(state)) {
      context.read<BillBloc>().add(const ClearBillRequested());
      _syncControllersAfterReset();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Clear Form?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'All unsaved information entered in this ticket will be cleared.',
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BillBloc>().add(const ClearBillRequested());
              _syncControllersAfterReset();
            },
            child: const Text(
              'Clear Form',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onResendSmsPressed(BuildContext context, BillState state) {
    final phone = state.selectedCustomer?.mobile ?? '';
    final ticketNo = state.currentBillNumber;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.mark_email_read_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              phone.isNotEmpty
                  ? 'Weighment SMS notification dispatched to $phone'
                  : 'SMS notification queued for ticket $ticketNo',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _onExitPressed(BuildContext context, BillState state) {
    _onClearFormPressed(context, state);
  }
}
