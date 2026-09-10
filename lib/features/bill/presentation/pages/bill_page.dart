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
              content: Text('Bill ${state.currentBillNumber} saved successfully'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.status == BillScreenStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 24),
                  _buildTopSection(state),
                  const SizedBox(height: 24),
                  _buildBillForm(state),
                  const SizedBox(height: 24),
                  _buildActionButtons(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BillState state) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Bill',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Capture weighment details and generate bill',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dateStr,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopSection(BillState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: WeightDisplay(
            netWeightTon: state.netWeightTon,
            firstWeight: state.firstWeightKg,
            secondWeight: state.secondWeightKg,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: RecentBillsPanel(
            recentBills: state.recentBills,
            parties: state.parties,
            vehicles: state.vehicles,
          ),
        ),
      ],
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
      onPartyChanged: (party) => context.read<BillBloc>().add(PartySelected(party)),
      onVehicleChanged: (vehicle) => context.read<BillBloc>().add(VehicleSelected(vehicle)),
      onMaterialChanged: (material) => context.read<BillBloc>().add(MaterialSelected(material)),
      onFirstWeightChanged: (v) => context.read<BillBloc>().add(FirstWeightChanged(v)),
      onSecondWeightChanged: (v) => context.read<BillBloc>().add(SecondWeightChanged(v)),
      onRateChanged: (v) => context.read<BillBloc>().add(RateChanged(v)),
      onRemarksChanged: (v) => context.read<BillBloc>().add(RemarksChanged(v)),
      onEntryTypeChanged: (v) => context.read<BillBloc>().add(EntryTypeChanged(v)),
      onPaymentModeChanged: (v) => context.read<BillBloc>().add(PaymentModeChanged(v)),
    );
  }

  Widget _buildActionButtons(BillState state) {
    final isSaving = state.status == BillScreenStatus.saving;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isSaving ? null : () => context.read<BillBloc>().add(const ClearBillRequested()),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            'Clear',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isSaving ? null : () => context.read<BillBloc>().add(const SaveBillRequested()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isSaving ? null : () => context.read<BillBloc>().add(const SaveBillRequested()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B7A3D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Save & Print',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
