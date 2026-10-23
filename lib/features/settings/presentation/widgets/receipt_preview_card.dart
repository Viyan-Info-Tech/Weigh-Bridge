import 'package:flutter/material.dart';

import '../../../../features/bill/domain/entities/weighment.dart';
import '../../../../features/bill/presentation/widgets/preprinted_ticket_preview.dart';
import '../../../../features/settings/domain/entities/billing_settings.dart';

/// A card wrapper that displays the live ticket preview.
///
/// The preview renders [PrePrintedTicketPreview] from the most recent
/// weighment - the same dual-copy layout the print dialog shows and the same
/// [PrePrintedTicketPdfGenerator] output the printer receives - so a change to
/// the print alignment reaches the preview, the slip dialog and the paper
/// together.
///
/// Only the dynamic values are drawn because only the dynamic values are
/// printed: the HMB Enterprises letterhead lives on the stationery, not in the
/// application.
class ReceiptPreviewCard extends StatelessWidget {
  const ReceiptPreviewCard({
    super.key,
    required this.settings,
    required this.showSerialNumber,
    required this.showVehicleNumber,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showRemarks,
    required this.showFooterNote,
    required this.latestWeighment,
    required this.isLoadingWeighment,
  });

  final BillingSettings settings;

  final bool showSerialNumber;
  final bool showVehicleNumber;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showRemarks;
  final bool showFooterNote;
  final Weighment? latestWeighment;
  final bool isLoadingWeighment;

  static final Weighment _sampleBill = Weighment(
    id: 0,
    billNumber: 'WB-00037',
    vehicleNumber: 'TN56VD5677',
    firstWeightKg: 200000,
    firstWeightType: 'GROSS',
    secondWeightKg: 10000,
    secondWeightType: 'TARE',
    netWeightKg: 190000,
    remarks: '',
    createdAt: DateTime(2026, 10, 7, 19, 40),
    updatedAt: DateTime(2026, 10, 7, 19, 40),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.visibility_rounded,
                    color: Color(0xFF0D3B82),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Ticket Preview',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isLoadingWeighment
                            ? 'Loading recent weighment data...'
                            : (latestWeighment == null
                                  ? 'Showing sample weighment (reflects print alignment in real time)'
                                  : 'Reflects print alignment in real time'),
                        softWrap: true,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // The Authentic Bill Canvas - matching Weighment Slip Dialog
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const standardSlipWidth = 640.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: standardSlipWidth,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: standardSlipWidth,
                        child: _buildSlip(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlip() {
    final bill = latestWeighment ?? _sampleBill;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: PrePrintedTicketPreview(
          bill: bill,
          settings: settings,
          showCaption: false,
        ),
      ),
    );
  }
}
