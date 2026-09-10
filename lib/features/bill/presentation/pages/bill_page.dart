import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import '../widgets/weight_display.dart';
import '../widgets/bill_form.dart';
import '../widgets/recent_bills_panel.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  @override
  void initState() {
    super.initState();
    context.read<BillBloc>().add(const LoadBillScreen());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(
      listener: (context, state) {
        if (state.status == BillScreenStatus.saved) {
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
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Desktop Widescreen Layout: Left Form + Right Fully Recent Billings
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
                              // LEFT SIDE: Form & Live Scale Controls (57%)
                              Expanded(
                                flex: 57,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      WeightDisplay(
                                        netWeightTon: state.netWeightTon,
                                        firstWeight: state.firstWeightKg,
                                        secondWeight: state.secondWeightKg,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildBillForm(state),
                                      const SizedBox(height: 16),
                                      _buildActionButtons(state),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),

                              // Subtle Vertical Divider
                              Container(
                                width: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                color: const Color(0xFFE2E8F0),
                              ),

                              // RIGHT SIDE: Fully Recent Billings (43%)
                              Expanded(
                                flex: 43,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: RecentBillsPanel(
                                    recentBills: state.recentBills,
                                    parties: state.parties,
                                    vehicles: state.vehicles,
                                    materials: state.materials,
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

                // Compact Window Layout: Stacked Scrollable View
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopHeader(state),
                      const SizedBox(height: 16),
                      WeightDisplay(
                        netWeightTon: state.netWeightTon,
                        firstWeight: state.firstWeightKg,
                        secondWeight: state.secondWeightKg,
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
                          parties: state.parties,
                          vehicles: state.vehicles,
                          materials: state.materials,
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
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

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
            child: const Icon(Icons.scale_rounded,
                color: Color(0xFF0F52BA), size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weighbridge Billing Terminal',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Operator scale console • Ticket generation',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 12, color: const Color(0xFFCBD5E1)),
                const SizedBox(width: 10),
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F52BA),
                  ),
                ),
              ],
            ),
          ),
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
      selectedMaterial: state.selectedMaterial,
      entryType: state.entryType,
      paymentMode: state.paymentMode,
      firstWeightText: state.firstWeightText,
      secondWeightText: state.secondWeightText,
      rateText: state.rateText,
      netWeightKg: state.netWeightKg,
      amount: state.amount,
      remarksText: state.remarksText,
      onPartyChanged: (party) =>
          context.read<BillBloc>().add(PartySelected(party)),
      onVehicleChanged: (vehicle) =>
          context.read<BillBloc>().add(VehicleSelected(vehicle)),
      onMaterialChanged: (material) =>
          context.read<BillBloc>().add(MaterialSelected(material)),
      onFirstWeightChanged: (v) =>
          context.read<BillBloc>().add(FirstWeightChanged(v)),
      onSecondWeightChanged: (v) =>
          context.read<BillBloc>().add(SecondWeightChanged(v)),
      onRateChanged: (v) => context.read<BillBloc>().add(RateChanged(v)),
      onRemarksChanged: (v) => context.read<BillBloc>().add(RemarksChanged(v)),
      onEntryTypeChanged: (v) =>
          context.read<BillBloc>().add(EntryTypeChanged(v)),
      onPaymentModeChanged: (v) =>
          context.read<BillBloc>().add(PaymentModeChanged(v)),
    );
  }

  Widget _buildActionButtons(BillState state) {
    final isSaving = state.status == BillScreenStatus.saving;

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
            onPressed: isSaving
                ? null
                : () => context
                    .read<BillBloc>()
                    .add(const ClearBillRequested()),
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
            onPressed: isSaving
                ? null
                : () => context.read<BillBloc>().add(const SaveBillRequested()),
            icon: isSaving
                ? const SizedBox.shrink()
                : const Icon(Icons.save_outlined, size: 16),
            label: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Ticket'),
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
            onPressed: isSaving
                ? null
                : () => context.read<BillBloc>().add(const SaveBillRequested()),
            icon: isSaving
                ? const SizedBox.shrink()
                : const Icon(Icons.print_rounded, size: 16),
            label: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save & Print Slip'),
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
}
