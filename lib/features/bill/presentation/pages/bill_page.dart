import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import '../widgets/weight_display.dart';
import '../widgets/bill_form.dart';
import '../widgets/quick_add_party_dialog.dart';
import '../widgets/quick_add_vehicle_dialog.dart';
import '../widgets/quick_add_material_dialog.dart';
import '../widgets/recent_bills_panel.dart';
import '../widgets/live_date_time.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  late final TextEditingController _grossWeightController;
  late final TextEditingController _tareWeightController;
  late final TextEditingController _remarksController;
  String _weightUnit = 'kg';

  @override
  void initState() {
    super.initState();
    _grossWeightController = TextEditingController();
    _tareWeightController = TextEditingController();
    _remarksController = TextEditingController();
    _loadWeightUnit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillBloc>().add(const LoadBillScreen());
      }
    });
  }

  Future<void> _loadWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightUnit = prefs.getString('weightUnit') ?? 'kg';
    });
  }

  @override
  void dispose() {
    _grossWeightController.dispose();
    _tareWeightController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _syncControllersAfterReset() {
    _grossWeightController.clear();
    _tareWeightController.clear();
    _remarksController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.editingBillId != curr.editingBillId ||
          prev.currentBillNumber != curr.currentBillNumber,
      listener: (context, state) {
        if (state.status == BillScreenStatus.saved) {
          _syncControllersAfterReset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
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
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
        if (state.status == BillScreenStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 20),
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
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
        if (state.editingBillId != null && state.grossWeightText.isNotEmpty) {
          _grossWeightController.text = state.grossWeightText;
          _tareWeightController.text = state.tareWeightText;
          _remarksController.text = state.remarksText;
        } else if (state.editingBillId == null) {
          _syncControllersAfterReset();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1000) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTopHeader(state),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          Expanded(
                            flex: 57,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                   WeightDisplay(
                                     netWeightTon: state.netWeightKg / 1000,
                                     grossWeight: state.grossWeightKg,
                                     tareWeight: state.tareWeightKg,
                                     weightUnit: _weightUnit,
                                   ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _buildBillForm(state),
                                          const SizedBox(height: 16),
                                          _buildActionButtons(state),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                              Container(
                                width: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                color: const Color(0xFFE2E8F0),
                              ),
                              Expanded(
                                flex: 43,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: RecentBillsPanel(
                                    recentBills: state.recentBills,
                                    billsDate: state.effectiveBillsDate,
                                    billsStartDate: state.billsStartDate,
                                    billsEndDate: state.billsEndDate,
                                    parties: state.parties,
                                    vehicles: state.vehicles,
                                    vehicleTypes: state.vehicleTypes,
                                    materials: state.materials,
                                    onLoadPendingBill: (billId) {
                                      context.read<BillBloc>().add(LoadPendingBill(billId));
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
                                        context.read<BillBloc>().add(
                                          const LoadRecentBills(),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopHeader(state),
                      const SizedBox(height: 16),
                      WeightDisplay(
                        netWeightTon: state.netWeightKg / 1000,
                        grossWeight: state.grossWeightKg,
                        tareWeight: state.tareWeightKg,
                      ),
                      const SizedBox(height: 16),
                      _buildBillForm(state),
                      const SizedBox(height: 16),
                      _buildActionButtons(state),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 500,
                        child: RecentBillsPanel(
                          recentBills: state.recentBills,
                          billsDate: state.effectiveBillsDate,
                          billsStartDate: state.billsStartDate,
                          billsEndDate: state.billsEndDate,
                          parties: state.parties,
                          vehicles: state.vehicles,
                          vehicleTypes: state.vehicleTypes,
                          materials: state.materials,
                          onLoadPendingBill: (billId) {
                            context.read<BillBloc>().add(LoadPendingBill(billId));
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
                              context.read<BillBloc>().add(
                                const LoadRecentBills(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(BillState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F52BA).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Color(0xFF0F52BA), size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Viyan Weighbridge',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Billing & Ticket Management',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Spacer(),
          const LiveDateTime(),
        ],
      ),
    );
  }

  Widget _buildBillForm(BillState state) {
    return BillForm(
      billNumber: state.currentBillNumber,
      parties: state.parties,
      vehicles: state.vehicles,
      materials: state.materials,
      selectedParty: state.selectedParty,
      selectedVehicle: state.selectedVehicle,
      selectedVehicleType: state.selectedVehicleType,
      selectedMaterial: state.selectedMaterial,
      paymentMode: state.paymentMode,
      isEditing: state.isEditing,
      grossWeightController: _grossWeightController,
      tareWeightController: _tareWeightController,
      remarksController: _remarksController,
      netWeightKg: state.netWeightKg,
      vehicleCharge: state.vehicleCharge,
      defaultVehicleCharge: state.defaultVehicleCharge,
      isVehicleChargeManuallyEdited: state.isVehicleChargeManuallyEdited,
      amount: state.amount,
      weightUnit: _weightUnit,
      weightValidationError: state.weightValidationError,
      onPartyChanged: (party) =>
          context.read<BillBloc>().add(PartySelected(party)),
      onVehicleChanged: (vehicle) =>
          context.read<BillBloc>().add(VehicleSelected(vehicle)),
      onMaterialChanged: (material) =>
          context.read<BillBloc>().add(MaterialSelected(material)),
      onGrossWeightChanged: (v) =>
          context.read<BillBloc>().add(GrossWeightChanged(v)),
      onTareWeightChanged: (v) =>
          context.read<BillBloc>().add(TareWeightChanged(v)),
      onRemarksChanged: (v) =>
          context.read<BillBloc>().add(RemarksChanged(v)),
      onPaymentModeChanged: (v) =>
          context.read<BillBloc>().add(PaymentModeChanged(v)),
      onVehicleChargeChanged: (v) =>
          context.read<BillBloc>().add(VehicleChargeChanged(v)),
      onResetVehicleCharge: () =>
          context.read<BillBloc>().add(const ResetVehicleCharge()),
      onAddParty: () {
        QuickAddPartyDialog.show(
          context,
          onSave: (name, contactPerson) {
            context.read<BillBloc>().add(PartyQuickAddRequested(
              name: name,
              contactPerson: contactPerson,
            ));
          },
        );
      },
      onAddVehicle: () {
        final state = context.read<BillBloc>().state;
        QuickAddVehicleDialog.show(
          context: context,
          vehicleTypes: state.vehicleTypes,
          onSave: (vehicleNumber, vehicleTypeId) {
            context.read<BillBloc>().add(VehicleQuickAddRequested(
              vehicleNumber: vehicleNumber,
              vehicleTypeId: vehicleTypeId,
            ));
          },
          onAddVehicleType: (name, emptyPrice, loadPrice) {
            context.read<BillBloc>().add(VehicleTypeQuickAddRequested(
              name: name,
              emptyPrice: emptyPrice,
              loadPrice: loadPrice,
            ));
          },
        );
      },
      onAddMaterial: () {
        QuickAddMaterialDialog.show(
          context,
          onSave: (name) {
            context.read<BillBloc>().add(MaterialQuickAddRequested(name: name));
          },
        );
      },
    );
  }

  Widget _buildActionButtons(BillState state) {
    final isSaving = state.status == BillScreenStatus.saving || state.status == BillScreenStatus.printing;
    final isDisabled = isSaving || state.hasWeightError;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: isSaving ? null : () => _onClearFormPressed(context, state),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Clear Form'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: isDisabled
                ? null
                : () => context.read<BillBloc>().add(const SaveBillRequested()),
            icon: isSaving
                ? const SizedBox.shrink()
                : Icon(state.isEditing ? Icons.check_circle_outline : Icons.save_outlined, size: 16),
            label: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(state.isEditing ? 'Complete Weighment' : 'Save Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B82),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          ElevatedButton.icon(
            onPressed: isDisabled
                ? null
                : () => context.read<BillBloc>().add(const SaveAndPrintBillRequested()),
            icon: isSaving
                ? const SizedBox.shrink()
                : Icon(state.isEditing ? Icons.print_rounded : Icons.print_rounded, size: 16),
            label: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(state.isEditing ? 'Complete & Print Slip' : 'Save & Print Slip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _onClearFormPressed(BuildContext context, BillState state) {
    final hasData = state.selectedParty != null ||
        state.selectedVehicle != null ||
        state.selectedMaterial != null ||
        state.grossWeightText.isNotEmpty && state.grossWeightText != '0' ||
        state.tareWeightText.isNotEmpty && state.tareWeightText != '0' ||
        state.remarksText.isNotEmpty;

    if (!hasData) {
      context.read<BillBloc>().add(const ClearBillRequested());
      _syncControllersAfterReset();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Clear Form?',
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'All unsaved information entered in this ticket will be cleared.',
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BillBloc>().add(const ClearBillRequested());
              _syncControllersAfterReset();
            },
            child: const Text('Clear Form', style: TextStyle(fontFamily: 'PlusJakartaSans', color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
